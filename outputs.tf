output "gke_endpoint" {
  value       = module.kubernetes_engine.endpoint
  sensitive   = true
  description = "The kubernetes endpoint."
}
output "gke_ca_certificate" {
  value       = module.kubernetes_engine.ca_certificate
  sensitive   = true
  description = "The kubernetes CA certificate."
}
