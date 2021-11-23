variable "tfuser" {
  description = "Adds your name to the resources"
  type        = string
  default     = "andyg"
}

variable "cluster_name" {
  type    = string
  default = "k8s-cluster"
}

variable "region" {
  type    = string
  default = "us-gov-west-1"
}

variable "os" {
  type        = string
  description = "AWS AMI OS"
  default     = "ubuntu20"
}

// VPC CIDR

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

// Subnet CIDRs

variable "private_subnet_1_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "private_subnet_2_cidr" {
  type    = string
  default = "10.0.2.0/24"
}

variable "public_subnet_1_cidr" {
  type    = string
  default = "10.0.11.0/24"
}

variable "public_subnet_2_cidr" {
  type    = string
  default = "10.0.12.0/24"
}

variable "public_ssh_key" {
  type = string
}

variable "k3s_server_count" {
  type    = number
  default = 3
}

variable "k3s_server_size" {
  type    = string
  default = "t2.xlarge"
}

variable "k3s_agent_count" {
  type    = number
  default = 3
}

variable "k3s_agent_size" {
  type    = string
  default = "t2.xlarge"
}

variable "amis" {
  description = "List of amis and default users by region"
  type = map(map(object({
    ami  = string
    user = string
  })))
  default = {
    "us-east-1" = {
      "ubuntu20" = {
        ami  = "ami-0ac80df6eff0e70b5"
        user = "ubuntu"
      }
    }
    "us-gov-west-1" = {
      "rhel8" = {
        ami  = "ami-0ac4e06a69870e5be"
        user = "ec2-user"
      }
      "rhel7" = {
        ami  = "ami-e9d5ec88"
        user = "ec2-user"
      }
      "sles15sp2" = {
        ami  = "ami-04e3d865"
        user = "ec2-user"
      }
      "ubuntu20" = {
        ami  = "ami-84556de5"
        user = "ubuntu"
      }
      "ubuntu18" = {
        ami  = "ami-bce9d3dd"
        user = "ubuntu"
      }
      "centos8" = {
        ami  = "ami-967158f7"
        user = "centos"
      }
      "centos7" = {
        ami  = "ami-bbba86da"
        user = "centos"
      }
      "rocky8" = {
        ami  = "ami-06370d1e5ddbf1f76"
        user = "ec2-user"
      }
    }
  }
}

variable "is_public" {
  description = "pub nodes get pub id"
  type        = bool
}