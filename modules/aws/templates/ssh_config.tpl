Host bastion 
  Hostname 52.61.58.249
  User ${user}
  IdentityFile ~/.ssh/rancher-laptop

Host master
  Hostname 10.0.12.90
  User ${user}
  IdentityFile ~/.ssh/rancher-laptop
  ProxyJump bastion

