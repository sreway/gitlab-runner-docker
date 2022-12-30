variable "sel_user_name" {
  type        = string
  description = "Name of user for access to Selectel VPC project"
}

variable "sel_user_password" {
  type        = string
  description = "Password of user for access to Selectel VPC project"
}

variable "sel_api_key" {
  type        = string
  description = "Selectel API key. Can be create: https://my.selectel.ru/profile/apikeys"
}

variable "sel_project_name" {
  type        = string
  default     = "sreway"
  description = "Selectel VPC project name"
}

variable "sel_project_id" {
  type        = string
  description = "Selectel VPC project ID"
}

variable "sel_account_id" {
  type        = string
  description = "Selectel account id. (contract number)"
}

variable "sel_auth_url" {
  type        = string
  default     = "https://api.selvpc.ru/identity/v3"
  description = "Auth url of Selectel VPC API."
}

variable "sel_region_name" {
  type        = string
  default     = "ru-7"
  description = "Name of region for Selectel VPC resources"
}

variable "sel_ssh_key_name" {
  type        = string
  default     = "andy"
  description = "The name of the SSH key pair to put on the compute instance. The key pair must already be created in some region and associated with Selectel vpc project"
}

variable "networks" {
  type = map(object({
    name            = string
    subnet_cidr     = string
    router_name     = string
    dns_nameservers = list(string)
    tags            = list(string)
  }))

  default = {
    "gitlab-runners-net" = {
      name            = "gitlab-runners-net"
      subnet_cidr     = "192.168.1.0/24"
      router_name     = "gitlab-runners-router"
      enable_dhcp     = false
      dns_nameservers = ["188.93.16.19", "188.93.17.19"]
      tags            = ["gitlab_runners_net"]
    }
  }
  description = "Hash map of Virtual Private Cloud network settings that should be created"
}


variable "instances" {
  type = map(object({
    name               = string
    vcpus              = number
    ram                = number
    disk               = number
    disk_remote        = bool
    disk_type          = string
    image              = string
    zone               = string
    network_name       = string
    create_floating_ip = bool
    tags               = list(string)
  }))

  default = {
    "gitlab-runner-01" = {
      disk               = 40
      disk_remote        = true
      disk_type          = "basic"
      image              = "Ubuntu 22.04 LTS 64-bit"
      name               = "gitlab-runner-01"
      ram                = 4096
      vcpus              = 2
      zone               = "ru-7a"
      network_name       = "gitlab-runners-net"
      create_floating_ip = true
      tags               = ["gitlab_runner", "docker", "preemptible"]
    },
  }

  description = "Hash map of instances setting that should be created"
}

variable "ssh_user" {
  type        = string
  default     = "is"
  description = "SSH username administrator on compute nodes (sudoers)"
}

variable "ssh_public_key" {
  type        = string
  description = "SSH public key on compute nodes"
}

variable "gitlab_url" {
  type        = string
  description = "Gitlab URL"
}

variable "gitlab_token" {
  type        = string
  description = "Gitlab registration token"
}
