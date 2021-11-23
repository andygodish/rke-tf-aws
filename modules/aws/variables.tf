variable "tfuser" {
  description = "Adds your name to the resources"
  type = string
}

variable "cluster_name" {
  type = string
}

variable "region" {
  type    = string
}

variable "public_ssh_key" {
  type = string
}

variable "vpc_cidr" {
  type = string
  default = "10.0.0.0/16"
}

variable "private_subnet_1_cidr" {
  type = string
  default = "10.0.1.0/24"
}

variable "private_subnet_2_cidr" {
  type = string
  default = "10.0.2.0/24"
}

variable "public_subnet_1_cidr" {
  type = string
  default = "10.0.11.0/24"
}

variable "public_subnet_2_cidr" {
  type = string
  default = "10.0.12.0/24"
}

########## SERVER #########
variable "k3s_server_count" {
  type = number
}

variable "k3s_server_size" {
  type = string
  default = "t2.xlarge"
}

########## AGENT ##########
variable "k3s_agent_count" {
  type = number
}

variable "k3s_agent_size" {
  type = string
  default = "t2.xlarge"
}

variable "amis" {
  type = map(map(object({
    ami  = string
    user = string
  })))
}

variable "os" {
  type        = string
  description = "AWS AMI OS"
  default     = "ubuntu20"
}

variable "is_public" {
  type = bool
}

variable "ssh_private_key" {
  type        = string
  description = "SSH private key used to connect into instances"
  default     = "~/.ssh/rancher-laptop"
}