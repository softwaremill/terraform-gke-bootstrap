module "gke" {
  source               = "../../../"
  region               = "europe-central2"
  create_project       = false
  project_id           = "<PROJECT_ID>" // replace with your project id
  platform_name        = "test"
  subnet_network       = "10.1.0.0/16"
  k8s_network_base     = "10.100.0.0/16"
  regional             = false
  zones                = ["europe-central2-a"]
  enable_private_nodes = false
  node_pools = [
    {
      name         = "default-pool"
      disk_size_gb = 50
      max_count    = 3
      preemptible  = true
    }
  ]
}
