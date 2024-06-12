output "gke_cluster_name" {
  value       = google_container_cluster.gke.name
  description = "Cluster name"
}

output "gke_cluster_id" {
  value       = google_container_cluster.gke.id
  description = "Cluster name"
}

output "gke_endpoint" {
  value       = google_container_cluster.gke.endpoint
  sensitive   = true
  description = "The kubernetes endpoint"
}
output "gke_ca_certificate" {
  value       = google_container_cluster.gke.master_auth.0.cluster_ca_certificate
  sensitive   = true
  description = "The kubernetes CA certificate"
}
output "gke_location" {
  value       = google_container_cluster.gke.location
  description = "Location of the GKE cluster. Region if cluster is regional, zone if zonal"
}
output "project_id" {
  value       = local.project_id
  description = "ID of the project containing the cluster"
}
output "vpc_name" {
  value       = module.network.network_name
  description = "Name of the created VPC (network)"
}
output "vpc_id" {
  value       = module.network.network_id
  description = "VPC (network) ID"
}
output "vpc_self_link" {
  value       = module.network.network_self_link
  description = "VPC (network) self link"
}
output "gke_zones" {
  value       = google_container_cluster.gke.node_locations
  description = "List of zones where the cluster lives"
}
output "nat_ip" {
  value       = module.cloud_nat.*.cloud_nat_ip
  description = "The IP address allocated for NAT"
}
output "subnetwork_name" {
  value       = module.network.subnets_names.0
  description = "Name of the subnetwork"
}
