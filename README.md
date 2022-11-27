# Example Docker Gitlab runner creation via terraform and ansible

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_local"></a> [local](#provider\_local) | 2.2.3 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ansible_inventory"></a> [ansible\_inventory](#module\_ansible\_inventory) | [git](https://github.com/sreway/terraform-selectel-modules/tree/main/modules/vpc/ansible_inventory) | n/a |
| <a name="module_available_instances"></a> [available\_instances](#module\_available\_instances) | [git](https://github.com/sreway/terraform-selectel-modules/tree/main/modules/vpc/datasource/available_instances) | n/a |
| <a name="module_floating_ip_mapping"></a> [floating\_ip\_mapping](#module\_floating\_ip\_mapping) | [git](https://github.com/sreway/terraform-selectel-modules/tree/main/modules/vpc/network/floating_ip_mapping) | n/a |
| <a name="module_instance"></a> [instance](#module\_instance) | [git](https://github.com/sreway/terraform-selectel-modules/tree/main/modules/vpc/instance) | n/a |
| <a name="module_internal_network"></a> [internal\_network](#module\_internal\_network) |[git](https://github.com/sreway/terraform-selectel-modules/tree/main/modules/vpc/network/internal_network) | n/a |
| <a name="module_router"></a> [router](#module\_router) | [git](https://github.com/sreway/terraform-selectel-modules/tree/main/modules/vpc/network/router) | n/a |

## Resources

| Name | Type |
|------|------|
| [local_file.ansible_inventory](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [null_resource.deploy_inventory](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_gitlab_token"></a> [gitlab\_token](#input\_gitlab\_token) | Gitlab registration token | `string` | n/a | yes |
| <a name="input_gitlab_url"></a> [gitlab\_url](#input\_gitlab\_url) | Gitlab URL | `string` | n/a | yes |
| <a name="input_instances"></a> [instances](#input\_instances) | Hash map of instances setting that should be created | <pre>map(object({<br>    name         = string<br>    vcpus        = number<br>    ram          = number<br>    disk         = number<br>    image        = string<br>    zone         = string<br>    network_name = string<br>    remote_volumes = map(object({<br>      name = string<br>      size = number<br>      type = string<br>      zone = string<br>    }))<br>    create_floating_ip = bool<br>    tags               = list(string)<br>  }))</pre> | <pre>{<br>  "gitlab-runner-01": {<br>    "create_floating_ip": true,<br>    "disk": 40,<br>    "image": "Ubuntu 22.04 LTS 64-bit",<br>    "name": "gitlab-runner-01",<br>    "network_name": "gitlab-runners-net",<br>    "ram": 4096,<br>    "remote_volumes": {},<br>    "tags": [<br>      "gitlab_runner",<br>      "docker",<br>      "preemptible"<br>    ],<br>    "vcpus": 2,<br>    "zone": "ru-7a"<br>  }<br>}</pre> | no |
| <a name="input_networks"></a> [networks](#input\_networks) | Hash map of Virtual Private Cloud network settings that should be created | <pre>map(object({<br>    name            = string<br>    subnet_cidr     = string<br>    router_name     = string<br>    dns_nameservers = list(string)<br>    tags            = list(string)<br>  }))</pre> | <pre>{<br>  "gitlab-runners-net": {<br>    "dns_nameservers": [<br>      "188.93.16.19",<br>      "188.93.17.19"<br>    ],<br>    "enable_dhcp": false,<br>    "name": "gitlab-runners-net",<br>    "router_name": "gitlab-runners-router",<br>    "subnet_cidr": "192.168.1.0/24",<br>    "tags": [<br>      "gitlab_runners_net"<br>    ]<br>  }<br>}</pre> | no |
| <a name="input_sel_account_id"></a> [sel\_account\_id](#input\_sel\_account\_id) | Selectel account id. (contract number) | `string` | n/a | yes |
| <a name="input_sel_api_key"></a> [sel\_api\_key](#input\_sel\_api\_key) | Selectel API key. Can be create: https://my.selectel.ru/profile/apikeys | `string` | n/a | yes |
| <a name="input_sel_auth_url"></a> [sel\_auth\_url](#input\_sel\_auth\_url) | Auth url of Selectel VPC API. | `string` | `"https://api.selvpc.ru/identity/v3"` | no |
| <a name="input_sel_project_id"></a> [sel\_project\_id](#input\_sel\_project\_id) | Selectel VPC project ID | `string` | n/a | yes |
| <a name="input_sel_project_name"></a> [sel\_project\_name](#input\_sel\_project\_name) | Selectel VPC project name | `string` | `"sreway"` | no |
| <a name="input_sel_region_name"></a> [sel\_region\_name](#input\_sel\_region\_name) | Name of region for Selectel VPC resources | `string` | `"ru-7"` | no |
| <a name="input_sel_ssh_key_name"></a> [sel\_ssh\_key\_name](#input\_sel\_ssh\_key\_name) | The name of the SSH key pair to put on the compute instance. The key pair must already be created in some region and associated with Selectel vpc project | `string` | `"andy"` | no |
| <a name="input_sel_user_name"></a> [sel\_user\_name](#input\_sel\_user\_name) | Name of user for access to Selectel VPC project | `string` | n/a | yes |
| <a name="input_sel_user_password"></a> [sel\_user\_password](#input\_sel\_user\_password) | Password of user for access to Selectel VPC project | `string` | n/a | yes |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | SSH public key on compute nodes | `string` | n/a | yes |
| <a name="input_ssh_user"></a> [ssh\_user](#input\_ssh\_user) | SSH username administrator on compute nodes (sudoers) | `string` | `"is"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ansible_inventory_data"></a> [ansible\_inventory\_data](#output\_ansible\_inventory\_data) | n/a |
<!-- END_TF_DOCS -->