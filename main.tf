provider "openstack" {
  user_name           = var.sel_user_name
  password            = var.sel_user_password
  tenant_name         = var.sel_project_name
  project_domain_name = var.sel_account_id
  user_domain_name    = var.sel_account_id
  auth_url            = var.sel_auth_url
  region              = var.sel_region_name
}

provider "selectel" {
  token = var.sel_api_key
}

// Create networks
module "internal_network" {
  source                 = "git::https://github.com/sreway/terraform-selectel-modules.git//modules/vpc/network/internal_network"
  for_each               = var.networks
  network_name           = each.value.name
  subnet_cidr            = each.value.subnet_cidr
  subnet_dns_nameservers = each.value.dns_nameservers
}

// Create routers for networks
module "router" {
  source      = "git::https://github.com/sreway/terraform-selectel-modules.git//modules/vpc/network/router"
  for_each    = module.internal_network
  router_name = var.networks[each.key].router_name
  subnet_id   = each.value.subnet_id
  depends_on = [
    module.internal_network
  ]
}

// Get available instances 
module "available_instances" {
  source = "git::https://github.com/sreway/terraform-selectel-modules.git//modules/vpc/datasource/available_instances"
  region = var.sel_region_name
}

// Create instances
module "instance" {
  source                 = "git::https://github.com/sreway/terraform-selectel-modules.git//modules/vpc/instance"
  for_each               = var.instances
  instance_name          = each.value.name
  instance_ram           = each.value.ram
  instance_vcpus         = each.value.vcpus
  instance_disk          = each.value.disk
  instance_disk_remote   = each.value.disk_remote
  instance_disk_type     = each.value.disk_type
  instance_image         = each.value.image
  instance_zone          = each.value.zone
  instance_network_id    = module.internal_network[each.value.network_name].network_id
  instance_subnet_id     = module.internal_network[each.value.network_name].subnet_id
  instance_tags          = each.value.tags
  instance_key_pair_name = var.sel_ssh_key_name

  depends_on = [
    module.internal_network
  ]
}

// Create floating ip addresses and mapping instances ports
module "floating_ip_mapping" {
  source     = "git::https://github.com/sreway/terraform-selectel-modules.git//modules/vpc/network/floating_ip_mapping"
  for_each   = { for k, v in module.instance : k => v if var.instances[k].create_floating_ip == true }
  port_id    = module.instance[each.key].port_id
  depends_on = [module.instance, module.internal_network]
}

// Add tag new_instance for recently createated compute instances (need for re-run apply when new instance added)
locals {
  instances = { for k, v in module.instance : k => {
    id           = v.id
    access_ip_v4 = v.access_ip_v4
    tags         = !contains(module.available_instances.instances, k) ? toset(concat(tolist(v.tags), ["new_instance"])) : v.tags
  } }
}

// Create ansible inventory
module "ansible_inventory" {
  source       = "git::https://github.com/sreway/terraform-selectel-modules.git//modules/vpc/ansible_inventory"
  instances    = local.instances
  floating_ips = module.floating_ip_mapping
  depends_on = [
    local.instances, module.floating_ip_mapping
  ]
}

// Create ansible inventory file
resource "local_file" "ansible_inventory" {
  content    = module.ansible_inventory.data
  filename   = "${path.module}/ansible/inventory/hosts.yml"
  depends_on = [module.ansible_inventory]
}


# // Run ansible playbook
resource "null_resource" "deploy_inventory" {
  triggers = {
    instances    = sha1(jsonencode(module.instance))
    floating_ips = sha1(jsonencode(module.floating_ip_mapping))
    // Destroy-time provisioners and their connection configurations may only reference attributes of the related resource, via ‘self’, ‘count.index’, or ‘each.key’.
    local_var_ssh_user = var.ssh_user
  }
  provisioner "local-exec" {
    working_dir = "${path.module}/ansible"
    command     = <<-EOT
      ansible-galaxy role install -r requirements.yml -p roles --force
      ansible-playbook -i inventory/ site.yml
    EOT
    environment = {
      ANSIBLE_FORCE_COLOR = 1
      SSH_USER            = var.ssh_user
      SSH_PUBLIC_KEY      = var.ssh_public_key
      GITLAB_URL          = var.gitlab_url
      GITLAB_REG_TOKEN    = var.gitlab_token
    }
    on_failure = continue
  }

  // Unregister runner before destroy
  provisioner "local-exec" {
    when        = destroy
    working_dir = "${path.module}/ansible"
    command     = "ansible-playbook -vvv -i inventory/ cleanup.yml"
    environment = {
      ANSIBLE_FORCE_COLOR = "1"
      SSH_USER            = "${self.triggers.local_var_ssh_user}"
    }
  }

  depends_on = [local_file.ansible_inventory]
}