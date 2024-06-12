variable "create_router" {
  type = bool
  default = true
}
variable "router" {
  type = string
}
variable "project_id" {
  type = string
}
variable "region" {
  type = string
}
variable "network" {
  type = string
}
variable "name" {
  type = string
}
variable "source_subnetwork_ip_ranges_to_nat" {
  type        = string
  description = "How NAT should be configured per Subnetwork. Valid values include: ALL_SUBNETWORKS_ALL_IP_RANGES, ALL_SUBNETWORKS_ALL_PRIMARY_IP_RANGES, LIST_OF_SUBNETWORKS. Changing this forces a new NAT to be created."
  default     = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
