# Terraform GKE module
This module creates the GKE cluster with all dependencies: project, network (VPC), subnet etc.
It can also use existing project - in such case set the `create_project` to `false` and provide the existing `project_id`.

## Usage

The simplest way to use this module:

```terraform
module "gke" {
  source = "../../"
  create_project = false
  k8s_network_base = "10.100.0.0/16"
  project_id = "gke-test-project"
  region = "europe-central2"
  subnet_network = "10.1.0.0/20"
  regional = false
  zones = ["europe-central2-a"]
  node_pools = [
    {
      name = "default-pool"
      disk_size_gb = 50
      max_count = 3
      preemptible = true
    }
  ]
}
```

By default, it creates a "private" GKE cluster, but this can be changed setting `enable_private_nodes` to `false`.
This module is based on opinionated google modules, but combines several modules into "one module to rule them all".
It uses the `private-cluster-update-variant` submodule of GKE - the version which can creates private cluster and - in case of node pool changes - creates new pool before deleting the old one, which minimizes the downtime of the live system.

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloud_nat"></a> [cloud\_nat](#module\_cloud\_nat) | registry.terraform.io/terraform-google-modules/cloud-nat/google | 2.2.0 |
| <a name="module_kubernetes_engine"></a> [kubernetes\_engine](#module\_kubernetes\_engine) | registry.terraform.io/terraform-google-modules/kubernetes-engine/google//modules/private-cluster-update-variant | 20.0.0 |
| <a name="module_network"></a> [network](#module\_network) | registry.terraform.io/terraform-google-modules/network/google | 5.0.0 |
| <a name="module_project"></a> [project](#module\_project) | registry.terraform.io/terraform-google-modules/project-factory/google | 13.0.0 |
| <a name="module_project_services"></a> [project\_services](#module\_project\_services) | registry.terraform.io/terraform-google-modules/project-factory/google//modules/project_services | 13.0.0 |

## Resources

| Name | Type |
|------|------|
| [google_compute_address.cloud_nat_address](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_activate_apis"></a> [activate\_apis](#input\_activate\_apis) | List of Google APIs activated in new or existing project. | `list(string)` | <pre>[<br>  "compute.googleapis.com",<br>  "container.googleapis.com"<br>]</pre> | no |
| <a name="input_billing_account"></a> [billing\_account](#input\_billing\_account) | The billing account to witch the new project should be connected. Required if `create_project` set to `true`. | `string` | `""` | no |
| <a name="input_create_project"></a> [create\_project](#input\_create\_project) | Defines if create the project. All resources are created this project. If `false` - the project\_id is required. | `bool` | `false` | no |
| <a name="input_enable_private_endpoint"></a> [enable\_private\_endpoint](#input\_enable\_private\_endpoint) | Defines if create private endpoint. It disables the public endpoint so the cluster is accessible only from VPC. | `bool` | `false` | no |
| <a name="input_enable_private_nodes"></a> [enable\_private\_nodes](#input\_enable\_private\_nodes) | Defines if use private nodes. Implies creation of cloud NAT service so nodes and pods can access public internet. | `bool` | `true` | no |
| <a name="input_k8s_network_base"></a> [k8s\_network\_base](#input\_k8s\_network\_base) | The IP CIDR base for pods and services secondary networks. Must not overlap with `subnet_network`. Must be a `/16` network. | `string` | n/a | yes |
| <a name="input_master_authorized_networks"></a> [master\_authorized\_networks](#input\_master\_authorized\_networks) | Allows accessing masters only from defined networks. If `enable_private_endpoint` is `true` it must not be any public CIDR block. | `list(map(string))` | <pre>[<br>  {<br>    "cidr_block": "0.0.0.0/0",<br>    "display_name": "ALL"<br>  }<br>]</pre> | no |
| <a name="input_master_ipv4_cidr_block"></a> [master\_ipv4\_cidr\_block](#input\_master\_ipv4\_cidr\_block) | The /28 CIDR block for masters when using private cluster. | `string` | `"172.16.0.0/28"` | no |
| <a name="input_node_pools"></a> [node\_pools](#input\_node\_pools) | List of node pools. To the details refer to https://github.com/terraform-google-modules/terraform-google-kubernetes-engine#node_pools-variable. | `list(map(string))` | <pre>[<br>  {<br>    "name": "default-node-pool"<br>  }<br>]</pre> | no |
| <a name="input_org_id"></a> [org\_id](#input\_org\_id) | GCP organization id. Required if `create_project` is `true`. | `string` | `""` | no |
| <a name="input_platform_name"></a> [platform\_name](#input\_platform\_name) | The name of the platform. Many resource names are based on this (VPC, subnet, GKE cluster etc). | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Existing project id. Required if `create_project` set to `false` | `string` | `""` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | The name of the created project. Defaults to `platform_name` if not set. | `string` | `""` | no |
| <a name="input_region"></a> [region](#input\_region) | Region where to create resources. | `string` | n/a | yes |
| <a name="input_regional"></a> [regional](#input\_regional) | Defines the type of the GKE cluster. If `true` - the cluster is created as `regional`. Otherwise - as `zonal`. | `bool` | `true` | no |
| <a name="input_release_channel"></a> [release\_channel](#input\_release\_channel) | The GKE release channel. | `string` | `"UNSPECIFIED"` | no |
| <a name="input_subnet_network"></a> [subnet\_network](#input\_subnet\_network) | The IP CIDR of the network for the GKE nodes. Must not overlap with `k8s_network_base`. | `string` | n/a | yes |
| <a name="input_zones"></a> [zones](#input\_zones) | List of zones for `zonal` cluster. Required if `regional` set to `false`. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_gke_endpoint"></a> [gke\_endpoint](#output\_gke\_endpoint) | The kubernetes endpoint |
<!-- END_TF_DOCS -->
