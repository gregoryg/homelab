# Terraform resources
# TODO: fix the timing hacks - "delay" should look for cluster readiness - kubectl cs perhaps
# TODO: Consider using the gavinbunney/kubectl provider
# TODO: Separate Control Plane/ Etcd and Worker roles on nodes
# TODO: Remove public IPs, provision bastion host
# TODO: Add storage to worker nodes
# Random ID
resource "random_id" "instance_id" {
 byte_length = 3
}

# Rancher cluster
resource "rancher2_cluster" "cluster_gg" {
  name         = "gg-${random_id.instance_id.hex}"
  description  = "Terraform"

  rke_config {
    kubernetes_version = var.k8version
    ignore_docker_version = false
    network {
      plugin = "flannel"
    }
    services {
      etcd {
        backup_config {
          enabled = false
        }
      }
      kubelet {
        extra_args  = {
          max_pods = 70
        }
      }
    }
  }
}

# resource "rancher2_node_pool" "masters" {
#   cluster_id = rancher2_cluster.cluster_gg.id
#   name = "control-etcd"
#   hostname_prefix = "gg-control-etcd"
#   node_template_id = google_compute_instance.vm_gg.id
#   quantity = 1
#   control_plane = true
#   etcd = true
#   worker = false
# }

# resource "rancher2_node_pool" "workers" {
#   cluster_id = rancher2_cluster.cluster_gg.id
#   name = "control-etcd"
#   hostname_prefix = "gg-control-etcd"
#   node_template_id = google_compute_instance.vm_gg.id
#   quantity = 1
#   control_plane = false
#   etcd = false
#   worker = true
# }

# Worker nodes and control plane
resource "google_compute_instance" "vm_gg" {
  name         = "gg-${random_id.instance_id.hex}-${count.index}"
  machine_type = var.type
  count = var.numnodes

  boot_disk {
    initialize_params {
      image = var.image
      size = var.disksize
    }
  }

  metadata = {
     ssh-keys = "rancher:${file("~/.ssh/google_compute_engine.pub")}"
  }

  metadata_startup_script = data.template_file.startup-script_data.rendered

  tags = ["http-server", "https-server"]

  network_interface {
    # A default network is created for all GG projects
    network       = "default"
    access_config {
    }
  }
}

# Delay hack part 1
resource "null_resource" "before" {
  depends_on = [rancher2_cluster.cluster_gg]
}

# Delay hack part 2
resource "null_resource" "delay" {
  provisioner "local-exec" {
    # command = "until echo \"${rancher2_cluster.cluster_gg.kube_config}\" > /tmp/k.yaml && kubectl --kubeconfig /tmp/k.yaml get cs ; do sleep 20s; done"
    command = "sleep ${var.delaysec}"
  }

  triggers = {
    "before" = "null_resource.before.id"
  }
}

# Kubeconfig file
resource "local_file" "kubeconfig" {
  filename = "${path.module}/.kube/config"
  content = rancher2_cluster.cluster_gg.kube_config
  file_permission = "0600"

  depends_on = [null_resource.delay]
}

# Cluster monitoring
resource "rancher2_app_v2" "monitor_gg" {
  lifecycle {
    ignore_changes = all
  }
  cluster_id = rancher2_cluster.cluster_gg.id
  name = "rancher-monitoring"
  namespace = "cattle-monitoring-system"
  repo_name = "rancher-charts"
  chart_name = "rancher-monitoring"
  chart_version = var.monchart
  values = templatefile("${path.module}/files/values.yaml", {})

  depends_on = [local_file.kubeconfig,rancher2_cluster.cluster_gg,google_compute_instance.vm_gg]
}

# Cluster logging CRD
resource "rancher2_app_v2" "syslog_crd_gg" {
  lifecycle {
    ignore_changes = all
  }
  cluster_id = rancher2_cluster.cluster_gg.id
  name = "rancher-logging-crd"
  namespace = "cattle-logging-system"
  repo_name = "rancher-charts"
  chart_name = "rancher-logging-crd"
  chart_version = var.logchart

  depends_on = [rancher2_app_v2.monitor_gg,rancher2_cluster.cluster_gg,google_compute_instance.vm_gg]
}

# Cluster logging
resource "rancher2_app_v2" "syslog_gg" {
  lifecycle {
    ignore_changes = all
  }
  cluster_id = rancher2_cluster.cluster_gg.id
  name = "rancher-logging"
  namespace = "cattle-logging-system"
  repo_name = "rancher-charts"
  chart_name = "rancher-logging"
  chart_version = var.logchart

  depends_on = [rancher2_app_v2.syslog_crd_gg,rancher2_cluster.cluster_gg,google_compute_instance.vm_gg]
}
