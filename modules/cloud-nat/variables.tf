variable "create_router" {
  type        = bool
  default     = true
  description = "Whether to create router or use the existing one."
}
variable "router" {
  type        = string
  description = "The name of the router to create or the existing one."
}
variable "project_id" {
  type        = string
  description = "GCP project where to create the resources."
}
variable "region" {
  type        = string
  description = "The GCP region."
}
variable "network" {
  type        = string
  description = "The VPC name."
}
variable "name" {
  type        = string
  description = "The name of the NAT router."
}
variable "source_subnetwork_ip_ranges_to_nat" {
  type        = string
  description = "How NAT should be configured per Subnetwork. Valid values include: ALL_SUBNETWORKS_ALL_IP_RANGES, ALL_SUBNETWORKS_ALL_PRIMARY_IP_RANGES, LIST_OF_SUBNETWORKS. Changing this forces a new NAT to be created."
  default     = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
