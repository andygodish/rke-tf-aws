# Configure the AWS Provider
provider "aws" {
  region = var.region
}

module "aws_infrastructure" {
  source = "./modules/aws"

  tfuser = var.tfuser
  cluster_name = var.cluster_name
  region    = var.region
  
  public_ssh_key = var.public_ssh_key

  k3s_server_count = var.k3s_server_count
  k3s_agent_count  = var.k3s_agent_count

  k3s_server_size = var.k3s_server_size
  k3s_agent_size  = var.k3s_agent_size

  amis      = var.amis
  os        = var.os
  is_public = var.is_public

}
