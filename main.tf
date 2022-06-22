module "project" {
  source            = "registry.terraform.io/terraform-google-modules/project-factory/google"
  version           = "13.0.0"
  billing_account   = var.billing_account
  name              = var.platform_name
  org_id            = var.org_id
  random_project_id = true
  activate_apis     = var.activate_apis
  count             = var.create_project ? 1 : 0
}

module "project_services" {
  source        = "registry.terraform.io/terraform-google-modules/project-factory/google//modules/project_services"
  version       = "13.0.0"
  project_id    = var.project_id
  activate_apis = var.activate_apis
  count         = var.create_project ? 0 : 1
}

module "network" {
  source                  = "registry.terraform.io/terraform-google-modules/network/google"
  version                 = "5.0.0"
  network_name            = var.platform_name
  project_id              = local.project_id
  auto_create_subnetworks = false
  subnets = [
    {
      subnet_name   = local.subnet_name
      subnet_ip     = var.subnet_network
      subnet_region = var.region
    }
  ]
  secondary_ranges = {
    (local.subnet_name) = [
      {
        ip_cidr_range = local.pods_ip_range
        range_name    = local.pods_network_name
      },
      {
        ip_cidr_range = local.services_ip_range
        range_name    = local.services_network_name
      }
    ]
  }
}

resource "google_compute_address" "cloud_nat_address" {
  name    = local.cloud_nat_name
  project = local.project_id
  region  = var.region
  count   = var.enable_private_nodes ? 1 : 0
}

module "cloud_nat" {
  source        = "registry.terraform.io/terraform-google-modules/cloud-nat/google"
  version       = "2.2.0"
  project_id    = local.project_id
  region        = var.region
  network       = module.network.network_name
  create_router = true
  router        = local.router
  name          = local.cloud_nat_name
  nat_ips       = [google_compute_address.cloud_nat_address.0.self_link]
  count         = var.enable_private_nodes ? 1 : 0
}

resource "google_container_cluster" "gke" {
  project                  = local.project_id
  name                     = var.platform_name
  location                 = local.location
  node_locations           = local.node_locations
  network                  = module.network.network_self_link
  subnetwork               = local.subnet_name
  remove_default_node_pool = true
  initial_node_count       = 1
  node_config {
    machine_type = var.default_pool_machine_type
  }
  confidential_nodes {
    enabled = var.enable_confidential_nodes
  }
  lifecycle {
    ignore_changes = [initial_node_count, node_config]
  }
}

resource "google_container_node_pool" "pools" {

  for_each       = local.node_pools
  location       = local.location
  project        = local.project_id
  cluster        = google_container_cluster.gke.name
  node_locations = lookup(each.value, "node_locations", "") != "" ? split(",", each.value["node_locations"]) : null
  node_count     = lookup(each.value, "autoscaling", true) ? null : lookup(each.value, "node_count", 1)
  dynamic "autoscaling" {
    for_each = lookup(each.value, "autoscaling", true) ? [each.value] : []
    content {
      min_node_count = lookup(autoscaling.value, "min_count", 1)
      max_node_count = lookup(autoscaling.value, "max_count", 100)
    }
  }
  node_config {
    image_type       = lookup(each.value, "image_type", "COS_CONTAINERD")
    machine_type     = lookup(each.value, "machine_type", "e2-medium")
    min_cpu_platform = lookup(var.node_pools[0], "min_cpu_platform", "")
    local_ssd_count  = lookup(each.value, "local_ssd_count", 0)
    disk_size_gb     = lookup(each.value, "disk_size_gb", 100)
    disk_type        = lookup(each.value, "disk_type", "pd-standard")
  }
  lifecycle {
    ignore_changes        = [initial_node_count]
    create_before_destroy = true
  }
}

# module "kubernetes_engine" {
#   source                     = "registry.terraform.io/terraform-google-modules/kubernetes-engine/google//modules/private-cluster-update-variant"
#   version                    = "20.0.0"
#   ip_range_pods              = local.pods_network_name
#   ip_range_services          = local.services_network_name
#   name                       = var.platform_name
#   network                    = module.network.network_name
#   project_id                 = local.project_id
#   subnetwork                 = local.subnet_name
#   release_channel            = var.release_channel
#   regional                   = var.regional
#   zones                      = var.zones
#   region                     = var.region
#   node_pools                 = var.node_pools
#   enable_private_endpoint    = var.enable_private_endpoint
#   enable_private_nodes       = var.enable_private_nodes
#   master_ipv4_cidr_block     = var.master_ipv4_cidr_block
#   depends_on                 = [module.project, module.project_services]
#   master_authorized_networks = var.master_authorized_networks
# }

resource "google_container_registry" "registry" {
  project  = local.project_id
  location = var.gcr_location
}
