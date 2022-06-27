variable "create_project" {
  type        = bool
  default     = false
  description = "Defines if create the project. All resources are created this project. If `false` - the project_id is required."
}
variable "billing_account" {
  type        = string
  default     = ""
  description = "The billing account to witch the new project should be connected. Required if `create_project` set to `true`."
}
variable "org_id" {
  type        = string
  default     = ""
  description = "GCP organization id. Required if `create_project` is `true`."
}
variable "region" {
  type        = string
  description = "Region where to create resources."
}
variable "project_id" {
  type        = string
  default     = ""
  description = "Existing project id. Required if `create_project` set to `false`"
}
variable "project_name" {
  type        = string
  default     = ""
  description = "The name of the created project. Defaults to `platform_name` if not set."
}
variable "release_channel" {
  type        = string
  default     = "UNSPECIFIED"
  description = "The GKE release channel."
}
variable "platform_name" {
  type        = string
  description = "The name of the platform. Many resource names are based on this (VPC, subnet, GKE cluster etc)."
}
variable "subnet_network" {
  type        = string
  description = "The IP CIDR of the network for the GKE nodes. Must not overlap with `k8s_network_base`."
}
variable "k8s_network_base" {
  type        = string
  description = "The IP CIDR base for pods and services secondary networks. Must not overlap with `subnet_network`. Must be a `/16` network."
}
variable "regional" {
  type        = bool
  default     = true
  description = "Defines the type of the GKE cluster. If `true` - the cluster is created as `regional`. Otherwise - as `zonal`."
}
variable "zones" {
  type        = list(string)
  default     = []
  description = "List of zones for `zonal` cluster. Required if `regional` set to `false`."
}
variable "node_pools" {
  type = list(map(string))
  default = [
    {
      name = "default-node-pool"
    },
  ]
  description = "List of node pools. To the details refer to https://github.com/terraform-google-modules/terraform-google-kubernetes-engine#node_pools-variable."
}

variable "node_pools_labels" {
  type = map(map(string))
  default = {
    "default-node-pool" = {
      node.pool / name = "default-node-pool"
    },
  }
  description = "List of node pools labels. https://registry.terraform.io/modules/terraform-google-modules/kubernetes-engine/google/21.1.0/submodules/private-cluster-update-variant?tab=inputs#:~:text=default%2Dnode%2Dpool%22%20%7D%20%5D-,node_pools_labels,-map(map(string"
}

variable "master_ipv4_cidr_block" {
  type        = string
  default     = "172.16.0.0/28"
  description = "The /28 CIDR block for masters when using private cluster."
}
variable "enable_private_endpoint" {
  type        = bool
  default     = false
  description = "Defines if create private endpoint. It disables the public endpoint so the cluster is accessible only from VPC."
}
variable "enable_private_nodes" {
  type        = bool
  default     = true
  description = "Defines if use private nodes. Implies creation of cloud NAT service so nodes and pods can access public internet."
}
variable "master_authorized_networks" {
  type = list(map(string))
  default = [
    {
      cidr_block   = "0.0.0.0/0"
      display_name = "ALL"
    }
  ]
  description = "Allows accessing masters only from defined networks. If `enable_private_endpoint` is `true` it must not be any public CIDR block."
}
variable "activate_apis" {
  type = list(string)
  default = [
    "compute.googleapis.com",
    "container.googleapis.com"
  ]
  description = "List of Google APIs activated in new or existing project."
}
variable "gcr_location" {
  type        = string
  default     = "EU"
  description = "Location of the GCR bucket."
}
