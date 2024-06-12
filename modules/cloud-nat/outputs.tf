output "cloud_nat_ip" {
  value = google_compute_address.cloud_nat_address.address
}
