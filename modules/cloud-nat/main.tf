resource "google_compute_router" "router" {
  count   = var.create_router ? 1 : 0
  name    = var.router
  project = var.project_id
  region  = var.region
  network = var.network
}

resource "google_compute_address" "cloud_nat_address" {
  name    = var.name
  project = var.project_id
  region  = var.region
}

resource "google_compute_router_nat" "main" {
  project                            = var.project_id
  region                             = var.region
  name                               = var.name
  router                             = local.router
  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = [google_compute_address.cloud_nat_address.self_link]
  source_subnetwork_ip_ranges_to_nat = var.source_subnetwork_ip_ranges_to_nat
}
