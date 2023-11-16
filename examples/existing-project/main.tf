module "gke" {
  source                      = "../../"
  region                      = "europe-central2"
  create_project              = false
  project_id                  = var.project_id
  platform_name               = var.platform_name
  disable_services_on_destroy = false
  subnet_network              = "10.1.0.0/16"
  k8s_network_base            = "10.100.0.0/16"
  regional                    = false
  zones                       = ["europe-central2-a"]
  node_pools = {
    default-pool = {
      disk_size_gb = 50
      max_count    = 3
      preemptible  = true
    }
  }
}
