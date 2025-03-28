# Terraform GKE module
This module creates the GKE cluster with all dependencies: project, network (VPC), subnet etc.
It can also use existing project - in such case set the `create_project` to `false` and provide the existing `project_id`.

# Prerequisite

- Before you create GCP project make sure you have right permission to attach billing accounts to created project. 
That means have at least one of IAM roles attached:
  - roles/billing.creator
  - roles/billing.admin
  - roles/billing.user
  - roles/billing.projectManager

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
  node_pools = {
    default-pool = {
      disk_size_gb = 50
      max_count = 3
      preemptible = true
    }
  }
}
```

By default, it creates a "private" GKE cluster, but this can be changed setting `enable_private_nodes` to `false`.
This module is based on opinionated google modules, but combines several modules into "one module to rule them all".
It uses the `private-cluster-update-variant` submodule of GKE - the version which can creates private cluster and - in case of node pool changes - creates new pool before deleting the old one, which minimizes the downtime of the live system.

## Node pools variable
The `node_pools` is a map of objects, where the node pool name is a key. Possible values:

| Name | Description                                                                                                                                                                                                                                                                                                                                                                 | Default |
|------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------|
| image_type | The image type used to create the nodes. The possible values are COS_CONTAINERD, COS, UBUNTU_CONTAINERD, UBUNTU. NOTE : COS AND UBUNTU are deprecated as of GKE 1.24                                                                                                                                                                                                        | COS_CONTAINERD |
| machine_type | The name of a Google Compute Engine machine type.                                                                                                                                                                                                                                                                                                                           | e2-medium |
| min_cpu_platform | Minimum CPU platform to be used by this instance. The instance may be scheduled on the specified or newer CPU platform. Applicable values are the friendly names of CPU platforms, such as Intel Haswell. See the [official documentation](https://cloud.google.com/compute/docs/instances/specify-min-cpu-platform) for more information.                                  | "" |
| local_ssd_count | Number of local SSDs to use to back ephemeral storage. Uses NVMe interfaces. Each local SSD is 375 GB in size. If zero, it means to disable using local SSDs as ephemeral storage.                                                                                                                                                                                          | 0 |
| disk_size_gb | Size of the disk attached to each node, specified in GB.                                                                                                                                                                                                                                                                                                                    | 100 |
| disk_type | Type of the disk attached to each node (e.g. 'pd-standard', 'pd-ssd' or 'pd-balanced').                                                                                                                                                                                                                                                                                                                                                                            | pd-standard |
| preemptible | A boolean that represents whether or not the underlying node VMs are preemptible                                                                                                                                                                                                                                                                                            | false |
| spot | A boolean that represents whether the underlying node VMs are spot.                                                                                                                                                                                                                                                                                                         | false |
| labels | The Kubernetes labels (key/value pairs) to be applied to each node. The kubernetes.io/ and k8s.io/ prefixes are reserved by Kubernetes Core components and cannot be specified.                                                                                                                                                                                             | {} |
| oauth_scopes | The set of Google API scopes to be made available on all of the node VMs under the "default" service account. Use the "https://www.googleapis.com/auth/cloud-platform" scope to grant access to all APIs. It is recommended that you set service_account to a non-default service account and grant IAM roles to that service account for only the resources that it needs. | var.default_node_pools_oauth_scopes |
| service_account | The service account to be used by the Node VMs. If not specified, the "default" service account is used.                                                                                                                                                                                                                                                                                                                                                                            | null |
| taint | A list of Kubernetes taints to apply to nodes. Each taint consist of `key`, `value` and the effect, which must be one of NO_SCHEDULE, PREFER_NO_SCHEDULE, and NO_EXECUTE.                                                                                                                                                                                                   | [] | 




## Autopilot support
This module supports the autopilot GKE cluster. To create the autopilot cluster:
- set the `enable_autopilot` to `true`
- set the `node_pools` variable to empty list `[]`

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 5.45.2 |
| <a name="provider_google-beta"></a> [google-beta](#provider\_google-beta) | 5.45.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloud_nat"></a> [cloud\_nat](#module\_cloud\_nat) | registry.terraform.io/terraform-google-modules/cloud-nat/google | 5.1.0 |
| <a name="module_network"></a> [network](#module\_network) | registry.terraform.io/terraform-google-modules/network/google | 9.1.0 |
| <a name="module_project"></a> [project](#module\_project) | registry.terraform.io/terraform-google-modules/project-factory/google | 15.0.1 |
| <a name="module_project_services"></a> [project\_services](#module\_project\_services) | terraform-google-modules/project-factory/google//modules/project_services | 15.0.1 |

## Resources

| Name | Type |
|------|------|
| [google-beta_google_container_node_pool.pools](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_container_node_pool) | resource |
| [google_artifact_registry_repository.my-repo](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/artifact_registry_repository) | resource |
| [google_compute_address.cloud_nat_address](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_container_cluster.gke](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_activate_apis"></a> [activate\_apis](#input\_activate\_apis) | List of Google APIs activated in new or existing project. | `list(string)` | <pre>[<br/>  "compute.googleapis.com",<br/>  "container.googleapis.com"<br/>]</pre> | no |
| <a name="input_artifact_registry_name"></a> [artifact\_registry\_name](#input\_artifact\_registry\_name) | The name of the artifact registry repository | `string` | `"my-repository"` | no |
| <a name="input_billing_account"></a> [billing\_account](#input\_billing\_account) | YOU NEED TO HAVE PERMISSION TO BILLING ACCOUNT, The billing account to witch the new project should be connected. Required if `create_project` set to `true`. | `string` | `""` | no |
| <a name="input_cluster_deletion_protection"></a> [cluster\_deletion\_protection](#input\_cluster\_deletion\_protection) | Whether or not to allow Terraform to destroy the cluster. Unless this field is set to false in Terraform state, a terraform destroy or terraform apply that would delete the cluster will fail. | `bool` | `true` | no |
| <a name="input_create_artifact_registry"></a> [create\_artifact\_registry](#input\_create\_artifact\_registry) | Whether to create Artifact Registry for docker images | `bool` | `false` | no |
| <a name="input_create_project"></a> [create\_project](#input\_create\_project) | Defines if create the project. All resources are created this project. If `false` - the project\_id is required. | `bool` | `false` | no |
| <a name="input_default_node_pools_oauth_scopes"></a> [default\_node\_pools\_oauth\_scopes](#input\_default\_node\_pools\_oauth\_scopes) | Default node pool oauth scopes added to all node pools | `list(string)` | <pre>[<br/>  "https://www.googleapis.com/auth/cloud-platform"<br/>]</pre> | no |
| <a name="input_default_pool_machine_type"></a> [default\_pool\_machine\_type](#input\_default\_pool\_machine\_type) | In some cases the GKE won't be created unless the default pool uses specific machine type (for example confidential nodes) so we have to set the type even if the default pool is removed. | `string` | `"e2-small"` | no |
| <a name="input_disable_services_on_destroy"></a> [disable\_services\_on\_destroy](#input\_disable\_services\_on\_destroy) | Whether project services will be disabled when the resources are destroyed. | `bool` | `true` | no |
| <a name="input_enable_autopilot"></a> [enable\_autopilot](#input\_enable\_autopilot) | Whether to enable Autopilot feature | `bool` | `null` | no |
| <a name="input_enable_confidential_nodes"></a> [enable\_confidential\_nodes](#input\_enable\_confidential\_nodes) | Whether to enable confidential nodes. | `bool` | `false` | no |
| <a name="input_enable_private_endpoint"></a> [enable\_private\_endpoint](#input\_enable\_private\_endpoint) | Defines if create private endpoint. It disables the public endpoint so the cluster is accessible only from VPC. | `bool` | `false` | no |
| <a name="input_enable_private_nodes"></a> [enable\_private\_nodes](#input\_enable\_private\_nodes) | Defines if use private nodes. Implies creation of cloud NAT service so nodes and pods can access public internet. | `bool` | `true` | no |
| <a name="input_gcr_location"></a> [gcr\_location](#input\_gcr\_location) | Location of the GCR bucket. | `string` | `"EU"` | no |
| <a name="input_k8s_network_base"></a> [k8s\_network\_base](#input\_k8s\_network\_base) | The IP CIDR base for pods and services secondary networks. Must not overlap with `subnet_network`. Must be a `/16` network. | `string` | n/a | yes |
| <a name="input_master_authorized_networks"></a> [master\_authorized\_networks](#input\_master\_authorized\_networks) | Allows accessing masters only from defined networks. If `enable_private_endpoint` is `true` it must not be any public CIDR block. | `list(map(string))` | <pre>[<br/>  {<br/>    "cidr_block": "0.0.0.0/0",<br/>    "display_name": "ALL"<br/>  }<br/>]</pre> | no |
| <a name="input_master_ipv4_cidr_block"></a> [master\_ipv4\_cidr\_block](#input\_master\_ipv4\_cidr\_block) | The /28 CIDR block for masters when using private cluster. | `string` | `"172.16.0.0/28"` | no |
| <a name="input_node_pools"></a> [node\_pools](#input\_node\_pools) | The object which describes the node pools. The structure is described in the README file. | `any` | `{}` | no |
| <a name="input_org_id"></a> [org\_id](#input\_org\_id) | GCP organization id. Required if `create_project` is `true`. | `string` | `""` | no |
| <a name="input_platform_name"></a> [platform\_name](#input\_platform\_name) | The name of the platform. Many resource names are based on this (VPC, subnet, GKE cluster etc). | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Existing project id. Required if `create_project` set to `false` | `string` | `null` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | The name of the created project. Defaults to `platform_name` if not set. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | Region where to create resources. | `string` | n/a | yes |
| <a name="input_regional"></a> [regional](#input\_regional) | Defines the type of the GKE cluster. If `true` - the cluster is created as `regional`. Otherwise - as `zonal`. | `bool` | `true` | no |
| <a name="input_release_channel"></a> [release\_channel](#input\_release\_channel) | The GKE release channel. | `string` | `"UNSPECIFIED"` | no |
| <a name="input_subnet_network"></a> [subnet\_network](#input\_subnet\_network) | The IP CIDR of the network for the GKE nodes. Must not overlap with `k8s_network_base`. | `string` | n/a | yes |
| <a name="input_subnet_private_access"></a> [subnet\_private\_access](#input\_subnet\_private\_access) | Whether to enable google private IP access for the subnet | `bool` | `true` | no |
| <a name="input_zones"></a> [zones](#input\_zones) | List of zones for `zonal` cluster. Required if `regional` set to `false`. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_gke_ca_certificate"></a> [gke\_ca\_certificate](#output\_gke\_ca\_certificate) | The kubernetes CA certificate |
| <a name="output_gke_cluster_id"></a> [gke\_cluster\_id](#output\_gke\_cluster\_id) | Cluster name |
| <a name="output_gke_cluster_name"></a> [gke\_cluster\_name](#output\_gke\_cluster\_name) | Cluster name |
| <a name="output_gke_endpoint"></a> [gke\_endpoint](#output\_gke\_endpoint) | The kubernetes endpoint |
| <a name="output_gke_location"></a> [gke\_location](#output\_gke\_location) | Location of the GKE cluster. Region if cluster is regional, zone if zonal |
| <a name="output_gke_zones"></a> [gke\_zones](#output\_gke\_zones) | List of zones where the cluster lives |
| <a name="output_nat_ip"></a> [nat\_ip](#output\_nat\_ip) | The IP address allocated for NAT |
| <a name="output_project_id"></a> [project\_id](#output\_project\_id) | ID of the project containing the cluster |
| <a name="output_subnetwork_name"></a> [subnetwork\_name](#output\_subnetwork\_name) | Name of the subnetwork |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | VPC (network) ID |
| <a name="output_vpc_name"></a> [vpc\_name](#output\_vpc\_name) | Name of the created VPC (network) |
| <a name="output_vpc_self_link"></a> [vpc\_self\_link](#output\_vpc\_self\_link) | VPC (network) self link |
<!-- END_TF_DOCS -->

## node_pools variable
The node_pools variable takes the following parameters:

| Name                                                                            | Description                                                                                                                                                                                                                                | Default          | Requirement |
|---------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------| --- |
| <a name="autoscaling"></a> [autoscaling](#autoscaling)                          | Configuration required by cluster autoscaler to adjust the size of the node pool to the current cluster usage                                                                                                                              | `true`           | Optional |
| <a name="node_locations"></a> [node\_locations](#node\_locations)               | The list of zones in which the cluster's nodes are located. Nodes must be in the region of their regional cluster or in the same region as their cluster's zone for zonal clusters. Defaults to cluster level node locations if nothing is specified | `""`             | Optional |
| <a name="node_count"></a> [node\_count](#node\_count)                           | The number of nodes in the nodepool when autoscaling is false. Otherwise defaults to 1. Only valid for non-autoscaling clusters                                                                                                            | `1`              | Required |
| <a name="min_count"></a> [min\_count](#min\_count)                              | Minimum number of nodes in the NodePool. Must be >=0 and <= max_count. Should be used when autoscaling is true                                                                                                                             | `1`              | Optional |
| <a name="max_count"></a> [max\_count](#max\_count)                              | Maximum number of nodes in the NodePool. Must be >= min_count                                                                                                                                                                              | `100`            | Optional |
| <a name="image_type"></a> [image\_type](#image\_type)                           | The image type to use for this node. Note that changing the image type will delete and recreate all nodes in the node pool                                                                                                                 | `COS_CONTAINERD` | Optional |
| <a name="machine_type"></a> [machine\_type](#machine\_type)                     | The name of a Google Compute Engine machine type                                                                                                                                                                                           | `e2-medium`      | Optional |
| <a name="min_cpu_platform"></a> [min\_cpu\_platform](#min\_cpu\_platform)       | Minimum CPU platform to be used by the nodes in the pool. The nodes may be scheduled on the specified or newer CPU platform.                                                                                                               | `""`             | Optional |
| <a name="local_ssd_count"></a> [local\_ssd\_count](#local\_ssd\_count)          | The amount of local SSD disks that will be attached to each cluster node and may be used as a `hostpath` volume or a `local` PersistentVolume.                                                                                             | `0`              | Optional |
| <a name="disk_size_gb"></a> [disk\_size\_gb](#disk\_size\_gb)                   | Size of the disk attached to each node, specified in GB. The smallest allowed disk size is 10GB                                                                                                                                            | `100`            | Optional |
| <a name="preemptible"></a> [preemptible](#preemptible)                          | A boolean that represents whether or not the underlying node VMs are preemptible. See the [official documentation](https://cloud.google.com/container-engine/docs/preemptible-vm)</a> for more information.)                               | `false`          | Optional |
| <a name="spot"></a> [spot](#spot)                                               | A boolean that represents whether the underlying node VMs are spot. See the [official documentation](https://cloud.google.com/kubernetes-engine/docs/concepts/spot-vms) for more information.                                              | `false`          | Optional |
| <a name="compact_placement_policy"></a> [compact\_placement\_policy](#compact\_placement\_policy) | Compact placement policy enabled places node pool's nodes in a closer physical proximity in order to reduce network latency between nodes.                                                                                                 | `false`          | Optional |
| <a name="taints"></a> [taints](#taints)                                         | List of objects, each object needs a `key`, `value`, and `effect` fields.                                                                                                  | `[]`             | Optional |
