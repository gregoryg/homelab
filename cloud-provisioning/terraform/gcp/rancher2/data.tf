# Run that startup script

# Registration command
data "template_file" "startup-script_data" {
  template = file("${path.module}/files/startup-script")
  vars = {
    registration_command = "${rancher2_cluster.cluster_gg.cluster_registration_token.0.node_command} --etcd --controlplane --worker"
  }
  depends_on = [rancher2_cluster.cluster_gg]
}
data "template_file" "startup-script_data_control" {
  template = file("${path.module}/files/startup-script")
  vars = {
    registration_command = "${rancher2_cluster.cluster_gg.cluster_registration_token.0.node_command} --etcd --controlplane"
  }
  depends_on = [rancher2_cluster.cluster_gg]
}
data "template_file" "startup-script_data_worker" {
  template = file("${path.module}/files/startup-script")
  vars = {
    registration_command = "${rancher2_cluster.cluster_gg.cluster_registration_token.0.node_command} --worker"
  }
  depends_on = [rancher2_cluster.cluster_gg]
}
