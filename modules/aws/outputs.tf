#############
# USER DATA #
#############

data "template_file" "server_userdata" {
  template = file("${path.module}/templates/server_userdata.sh")

  vars = {
    cp_lb_host = aws_elb.k8s_cp_elb.dns_name
  }
}

resource "local_file" "ssh_config" {
  content = templatefile("${path.module}/templates/ssh_config.tpl",
    {
      user = var.amis[var.region][var.os].user
    }
  )
  filename = "ssh_config"
}

# resource "local_file" "rke-ansibleInventory" {
#   content = templatefile("${path.module}/templates/rke_inventory.tpl",
#     {
#       control_node_public_dns = aws_instance.k8s_master_node.*.public_dns,
#       control_node_public_ip  = aws_instance.k8s_master_node.*.public_ip,
#       control_node_private_ip = aws_instance.k8s_master_node.*.private_ip
#       worker_node_public_dns  = aws_autoscaling_group.k8s_agent_asg.*.public_dns,
#       worker_node_public_ip   = aws_autoscaling_group.k8s_agent_asg.*.public_ip,
#       worker_node_private_ip  = aws_autoscaling_group.k8s_agent_asg.*.private_ip,
#       ansible_user            = var.amis[var.region][var.os].user
#       ssh_private_key         = var.ssh_private_key
#     }
#   )
#   filename = "rke_docker_install_hosts.ini"
}