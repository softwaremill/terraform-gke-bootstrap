module "gke" {
  source           = "../../"
  create_project   = true
  billing_account  = "017161-E22F28-B0ACBB"
  org_id           = "204964337255"
  k8s_network_base = "10.100.0.0/16"
  platform_name    = "test-gke"
  region           = "europe-central2"
  subnet_network   = "10.1.0.0/20"
  regional         = false
  zones            = ["europe-central2-a"]
  node_pools = [
    {
      name         = "default-pool"
      disk_size_gb = 50
      max_count    = 3
      preemptible  = true
    }
  ]
}
