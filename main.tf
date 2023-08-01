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
  source                      = "registry.terraform.io/terraform-google-modules/project-factory/google//modules/project_services"
  version                     = "13.0.0"
  project_id                  = var.project_id
  activate_apis               = var.activate_apis
  disable_services_on_destroy = var.disable_services_on_destroy
  count                       = var.create_project ? 0 : 1
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
  depends_on = [
    module.project_services.project_id
  ]
}

resource "google_compute_address" "cloud_nat_address" {
  name    = local.cloud_nat_name
  project = local.project_id
  region  = var.region
  count   = var.enable_private_nodes ? 1 : 0
  depends_on = [
    module.project_services.project_id
  ]
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
  depends_on = [
    module.project_services.project_id
  ]
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
  depends_on = [
    module.network.subnets
  ]
}

resource "google_container_node_pool" "pools" {
  provider       = google-beta
  for_each       = local.node_pools
  location       = local.location
  project        = local.project_id
  cluster        = google_container_cluster.gke.name
  node_locations = lookup(each.value, "node_locations", "") != "" ? split(",", each.value["node_locations"]) : null
  node_count     = lookup(each.value, "autoscaling", true) ? null : lookup(each.value, "node_count", 1)
  version        = lookup(each.value, "version", null)

  management {
    auto_upgrade = lookup(each.value, "auto_upgrade", true)
    auto_repair  = lookup(each.value, "auto_upgrade", false)
  }

  dynamic "autoscaling" {
    for_each = lookup(each.value, "autoscaling", true) ? [each.value] : []
    content {
      min_node_count = lookup(autoscaling.value, "min_count", 1)
      max_node_count = lookup(autoscaling.value, "max_count", 100)
    }
  }

  dynamic "placement_policy" {
    for_each = lookup(each.value, "compact_placement_policy", false) ? [each.value] : []
    content {
      type = "COMPACT"
    }
  }

  node_config {
    image_type       = lookup(each.value, "image_type", "COS_CONTAINERD")
    machine_type     = lookup(each.value, "machine_type", "e2-medium")
    min_cpu_platform = lookup(each.value, "min_cpu_platform", "")
    local_ssd_count  = lookup(each.value, "local_ssd_count", 0)
    disk_size_gb     = lookup(each.value, "disk_size_gb", 100)
    disk_type        = lookup(each.value, "disk_type", "pd-standard")
    preemptible      = lookup(each.value, "preemptible", false)
    spot             = lookup(each.value, "spot", false)
    labels           = lookup(var.node_pools_labels, each.value["name"], {})
    oauth_scopes     = lookup(local.node_pool_oauth_scopes, each.value["name"], [])


    dynamic "guest_accelerator" {
      for_each = lookup(each.value, "guest_accelerator", null) != null ? [1] : []
      content {
        type               = lookup(each.value["guest_accelerator"], "type", "")
        count              = lookup(each.value["guest_accelerator"], "count", 0)
        gpu_partition_size = lookup(each.value["guest_accelerator"], "gpu_partition_size", null)


        gpu_driver_installation_config {
          gpu_driver_version = lookup(each.value["guest_accelerator"], "gpu_driver_version", "DEFAULT")
        }

        dynamic "gpu_sharing_config" {
          for_each = lookup(each.value["guest_accelerator"], "gpu_sharing_config", null) != null ? [1] : []
          content {
            gpu_sharing_strategy       = lookup(gpu_sharing_config.value, "gpu_sharing_strategy", "TIME_SHARING")
            max_shared_clients_per_gpu = lookup(gpu_sharing_config.value, "max_shared_clients_per_gpu", 2)
          }
        }
      }
    }
  }
  lifecycle {
    ignore_changes        = [initial_node_count]
    create_before_destroy = true
  }
}

resource "google_container_registry" "registry" {
  project  = local.project_id
  location = var.gcr_location
}

