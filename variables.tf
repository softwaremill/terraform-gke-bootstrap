variable "create_project" {
  type        = bool
  default     = false
  description = "Defines if create the project. All resources are created this project. If `false` - the project_id is required."
}
variable "billing_account" {
  type        = string
  default     = ""
  description = "YOU NEED TO HAVE PERMISSION TO BILLING ACCOUNT, The billing account to witch the new project should be connected. Required if `create_project` set to `true`."
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
  default     = null
  description = "Existing project id. Required if `create_project` set to `false`"
  validation {
    condition     = var.project_id == null || can(regex("^[a-z]{1}[0-9a-z-]{5,29}$", var.project_id))
    error_message = "The project id must be 6 to 30 characters in length, can only contain lowercase letters, numbers, and hyphens"
  }
}
variable "project_name" {
  type        = string
  default     = null
  description = "The name of the created project. Defaults to `platform_name` if not set."
  validation {

    # condition     = (var.project_name == "" || length(var.project_name) < 25 && length(var.project_name) > 4)
    # error_message = "The project name should contain only 25 characters. Last 5 characters up to 30 total are generated"

    condition     = var.project_name == null || (can(length(var.project_name) < 25) && can(length(var.project_name) > 4))
    error_message = "The project name should contain more than 4 and less then 25 characters. Last 5 characters up to 30 total are generated"

  }
}
variable "release_channel" {
  type        = string
  default     = "UNSPECIFIED"
  description = "The GKE release channel."
  validation {
    condition     = contains(["UNSPECIFIED", "RAPID", "STABLE"], var.release_channel)
    error_message = "Valid values for var: test_variable are (UNSPECIFIED, RAPID, STABLE)"
  }
}
variable "platform_name" {
  type        = string
  description = "The name of the platform. Many resource names are based on this (VPC, subnet, GKE cluster etc)."
  validation {
    condition     = length(var.platform_name) < 25 && length(var.platform_name) > 4
    error_message = "The platform name should contain only 25 characters. Last 5 characters up to 30 total are generated"
  }
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
  type        = any
  default     = {}
  description = "The object which describes the node pools. The structure is described in the README file."
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
    "container.googleapis.com",
  ]
  description = "List of Google APIs activated in new or existing project."
}
variable "disable_services_on_destroy" {
  description = "Whether project services will be disabled when the resources are destroyed."
  default     = true
  type        = bool
}
variable "gcr_location" {
  type        = string
  default     = "EU"
  description = "Location of the GCR bucket."
}
variable "enable_confidential_nodes" {
  type        = bool
  default     = false
  description = "Whether to enable confidential nodes."
}
variable "default_pool_machine_type" {
  type        = string
  default     = "e2-small"
  description = "In some cases the GKE won't be created unless the default pool uses specific machine type (for example confidential nodes) so we have to set the type even if the default pool is removed."
}

variable "default_node_pools_oauth_scopes" {
  type = list(string)
  default = [
    "https://www.googleapis.com/auth/cloud-platform"
  ]
  description = "Default node pool oauth scopes added to all node pools"
}

variable "enable_autopilot" {
  type        = bool
  default     = null
  description = "Whether to enable Autopilot feature"
}

variable "subnet_private_access" {
  type        = bool
  default     = true
  description = "Whether to enable google private IP access for the subnet"
}

variable "create_artifact_registry" {
  type        = bool
  default     = false
  description = "Whether to create Artifact Registry for docker images"
}

variable "artifact_registry_name" {
  type        = string
  default     = "my-repository"
  description = "The name of the artifact registry repository"
}

variable "cluster_deletion_protection" {
  type        = bool
  default     = true
  description = "Whether or not to allow Terraform to destroy the cluster. Unless this field is set to false in Terraform state, a terraform destroy or terraform apply that would delete the cluster will fail."
}
