output "gke_cluster_name" {
  value = module.kubernetes_engine.name
  description = "Cluster name"
}
output "endpoint" {
  value       = module.kubernetes_engine.endpoint
  sensitive   = true
  description = "The kubernetes endpoint"
}
output "ca_certificate" {
  value       = module.kubernetes_engine.ca_certificate
  sensitive   = true
  description = "The kubernetes CA certificate"
}
