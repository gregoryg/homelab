# Terraform provider
# Google compute
provider "google" {
  project     = "rancher-dev"
  credentials = file("~/Downloads/rancher-dev-f2b25395df09.json")
  region      = "us-central1"
  zone        = "us-central1-c"
}

# Rancher
provider "rancher2" {
  # alias = "bootstrap"
  api_url = var.rancher-url
  token_key = var.rancher-token
  insecure = true
  # bootstrap = true
}
