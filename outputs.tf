output "gke_cluster_name" {
  value       = module.kubernetes_engine.name
  description = "Cluster name"
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
output "gke_zone" {
  value       = module.kubernetes_engine.zones
  description = "List of zones where the cluster lives"
}
