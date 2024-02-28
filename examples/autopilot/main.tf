module "gke" {
  source           = "../../"
  create_project   = false
  project_id       = var.project_id
  enable_autopilot = true
  billing_account  = var.billing_account
  org_id           = var.org_id
  k8s_network_base = "10.100.0.0/16"
  platform_name    = var.platform_name
  region           = "europe-central2"
  subnet_network   = "10.1.0.0/20"
  regional         = true
  node_pools       = {}
}
