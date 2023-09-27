locals {
  project_id            = var.create_project ? module.project.0.project_id : var.project_id
  project_name          = var.project_name != "" ? var.project_name : var.platform_name
  subnet_name           = "${var.platform_name}-subnet"
  router                = "${var.platform_name}-router"
  cloud_nat_name        = "${var.platform_name}-cloud-nat"
  pods_network_name     = "${local.subnet_name}-pods"
  services_network_name = "${local.subnet_name}-services"
  pods_ip_range         = cidrsubnet(var.k8s_network_base, 4, 1)
  services_ip_range     = cidrsubnet(var.k8s_network_base, 4, 2)
  location              = var.regional ? var.region : var.zones.0
  node_locations        = var.regional ? (length(var.zones) != 0 ? var.zones : null) : slice(var.zones, 1, length(var.zones))
}
