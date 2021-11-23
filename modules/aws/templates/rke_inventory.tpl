[all]
%{ for index, dns in control_node_public_ip ~}
${dns}
%{ endfor ~}
%{ for index, dns in worker_node_public_ip ~}
${dns}
%{ endfor ~}

[all:vars]
ansible_ssh_user=${ansible_user}
ansible_ssh_private_key_file=${ssh_private_key}
