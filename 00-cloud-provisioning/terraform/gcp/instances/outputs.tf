output "JBOV" {
  value = {
    ip = google_compute_address.vm_static_ip.address
    bucket = google_storage_bucket.example_bucket.name
  }
}
