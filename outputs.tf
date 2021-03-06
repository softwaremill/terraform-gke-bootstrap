output "gke_cluster_name" {
  value       = module.kubernetes_engine.name
  description = "Cluster name"
}
output "gke_cluster_id" {
  value       = module.kubernetes_engine.cluster_id
  description = "Cluster id"
}

output "gke_endpoint" {
  value       = module.kubernetes_engine.endpoint
  sensitive   = true
  description = "The kubernetes endpoint"
}
output "gke_ca_certificate" {
  value       = module.kubernetes_engine.ca_certificate
  sensitive   = true
  description = "The kubernetes CA certificate"
}
output "gke_location" {
  value       = module.kubernetes_engine.location
  description = "Location of the cluster"
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
output "gke_locaton" {
  value       = module.kubernetes_engine.location
  description = "Location of the GKE cluster. Region if cluster is regional, zone if zonal"
}
output "gke_zones" {
  value       = module.kubernetes_engine.zones
  description = "List of zones where the cluster lives"
}
