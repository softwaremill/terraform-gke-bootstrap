module "gke" {
  source           = "../../"
  create_project   = true
  billing_account  = var.billing_account
  org_id           = var.org_id
  k8s_network_base = "10.100.0.0/16"
  platform_name    = var.platform_name
  region           = "europe-central2"
  subnet_network   = "10.1.0.0/20"
  regional         = false
  zones            = ["europe-central2-a"]
  node_pools = {
    default-pool = {
      disk_size_gb = 50
      max_count    = 3
      labels = {
        "node.pool/name" = "default"
      }
      oauth_scopes = ["https://www.googleapis.com/auth/compute"]
      spot         = true
      taint = [
        {
          key    = "test"
          value  = "test"
          effect = "NO_SCHEDULE"
        }
      ]
    }
  }
}
