#################
# RANDOM APPEND #
#################

resource "random_string" "random_append" {
  length  = 6
  special = false
}

###########
# KEYPAIR #
###########

module "key_pair" {
  source = "terraform-aws-modules/key-pair/aws"

  key_name   = "${var.tfuser}-keypair"
  public_key = var.public_ssh_key
}

#############
# K3S TOKEN #
#############

resource "random_string" "k3s_token" {
  length  = 20
  special = false
}

###########
# BASTION #
###########

resource "aws_security_group" "bastion_sg" {
  name        = "bastion-ssh"
  description = "Allow traffic for K8S Control Plane"
  vpc_id      = aws_vpc.k8s_vpc.id

  ingress {
    description = "Ingress Bastion"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name                                        = "bastion-sg"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "KubernetesCluster"                         = var.cluster_name
    Owner                                       = var.tfuser
  }
}

resource "aws_instance" "bastion" {
  ami           = var.amis[var.region][var.os].ami
  instance_type = "t2.micro"

  subnet_id                   = aws_subnet.k8s_public_subnet_1.id
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true

  key_name = "${var.tfuser}-keypair"

  tags = {
    Name                                        = "k8s-bastion"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "KubernetesCluster"                         = var.cluster_name
    Owner                                       = var.tfuser
  }
}

###########
# MASTERS #
###########

resource "aws_security_group" "k8s_cp_sg" {
  name        = "k8s-cp-sg"
  description = "Allow traffic for K8S Control Plane"
  vpc_id      = aws_vpc.k8s_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name                                        = "k8s-cp-sg"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "KubernetesCluster"                         = var.cluster_name
    Owner                                       = var.tfuser
  }
}

resource "aws_security_group_rule" "k8s_cp_sg_self_ingress" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [aws_vpc.k8s_vpc.cidr_block]
  security_group_id = aws_security_group.k8s_cp_sg.id
}

resource "aws_security_group_rule" "k8s_cp_ingress" {
  description       = "Ingress Control Plane"
  type              = "ingress"
  from_port         = 6443
  to_port           = 6443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.k8s_cp_sg.id
}

resource "aws_iam_policy" "k8s_master_aws_iam_policy" {
  name        = "k8s-master-aws-iam-policy"
  path        = "/"
  description = "K8S Master AWS IAM Policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:DescribeLaunchConfigurations",
        "autoscaling:DescribeTags",
        "ec2:DescribeInstances",
        "ec2:DescribeRegions",
        "ec2:DescribeRouteTables",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSubnets",
        "ec2:DescribeVolumes",
        "ec2:CreateSecurityGroup",
        "ec2:CreateTags",
        "ec2:CreateVolume",
        "ec2:ModifyInstanceAttribute",
        "ec2:ModifyVolume",
        "ec2:AttachVolume",
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:CreateRoute",
        "ec2:DeleteRoute",
        "ec2:DeleteSecurityGroup",
        "ec2:DeleteVolume",
        "ec2:DetachVolume",
        "ec2:RevokeSecurityGroupIngress",
        "ec2:DescribeVpcs",
        "elasticloadbalancing:AddTags",
        "elasticloadbalancing:AttachLoadBalancerToSubnets",
        "elasticloadbalancing:ApplySecurityGroupsToLoadBalancer",
        "elasticloadbalancing:CreateLoadBalancer",
        "elasticloadbalancing:CreateLoadBalancerPolicy",
        "elasticloadbalancing:CreateLoadBalancerListeners",
        "elasticloadbalancing:ConfigureHealthCheck",
        "elasticloadbalancing:DeleteLoadBalancer",
        "elasticloadbalancing:DeleteLoadBalancerListeners",
        "elasticloadbalancing:DescribeLoadBalancers",
        "elasticloadbalancing:DescribeLoadBalancerAttributes",
        "elasticloadbalancing:DetachLoadBalancerFromSubnets",
        "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
        "elasticloadbalancing:ModifyLoadBalancerAttributes",
        "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
        "elasticloadbalancing:SetLoadBalancerPoliciesForBackendServer",
        "elasticloadbalancing:AddTags",
        "elasticloadbalancing:CreateListener",
        "elasticloadbalancing:CreateTargetGroup",
        "elasticloadbalancing:DeleteListener",
        "elasticloadbalancing:DeleteTargetGroup",
        "elasticloadbalancing:DescribeListeners",
        "elasticloadbalancing:DescribeLoadBalancerPolicies",
        "elasticloadbalancing:DescribeTargetGroups",
        "elasticloadbalancing:DescribeTargetHealth",
        "elasticloadbalancing:ModifyListener",
        "elasticloadbalancing:ModifyTargetGroup",
        "elasticloadbalancing:RegisterTargets",
        "elasticloadbalancing:DeregisterTargets",
        "elasticloadbalancing:SetLoadBalancerPoliciesOfListener",
        "iam:CreateServiceLinkedRole",
        "kms:DescribeKey",
        "ec2:DescribeInstances",
        "ec2:DescribeRegions",
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:GetRepositoryPolicy",
        "ecr:DescribeRepositories",
        "ecr:ListImages",
        "ecr:BatchGetImage"
      ],
      "Effect": "Allow",
      "Resource": ["*"]
    }
  ]
}
EOF
}

resource "aws_iam_role" "k8s_master_iam_role" {
  name = "k8s_server_role-${random_string.random_append.result}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
    Name                                        = "k8s_server_role"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "KubernetesCluster"                         = var.cluster_name
    Owner                                       = var.tfuser
  }
}

resource "aws_iam_role_policy_attachment" "k8s_master_aws_iam_attach" {
  role       = aws_iam_role.k8s_master_iam_role.name
  policy_arn = aws_iam_policy.k8s_master_aws_iam_policy.arn
}

resource "aws_iam_instance_profile" "k8s_master_iam_profile" {
  name = "k8s-master-iam-profile-${random_string.random_append.result}"
  role = aws_iam_role.k8s_master_iam_role.name
}

resource "aws_instance" "k8s_master_node" {
  count = var.k3s_server_count

  ami           = var.amis[var.region][var.os].ami
  instance_type = var.k3s_server_size
  subnet_id     = aws_subnet.k8s_public_subnet_1.id
  key_name      = "${var.tfuser}-keypair"

  root_block_device {
    volume_type = "standard"
    volume_size = 30
  }

  vpc_security_group_ids = [aws_security_group.k8s_cp_sg.id]

  iam_instance_profile = aws_iam_instance_profile.k8s_master_iam_profile.name

  tags = {
    Name                                        = "${var.tfuser}_control_node_${count.index}"
    Owner                                       = var.tfuser
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "KubernetesCluster"                         = var.cluster_name
  }
}

##########
# AGENTS #
##########

resource "aws_security_group" "k8s_agent_sg" {
  name        = "k8s-agent-sg"
  description = "Allow traffic for K8S Agent"
  vpc_id      = aws_vpc.k8s_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name                                        = "k8s-agent-sg"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "KubernetesCluster"                         = var.cluster_name
  }
}

resource "aws_security_group_rule" "k8s_agent_sg_http_ingress" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.k8s_agent_sg.id
}


resource "aws_security_group_rule" "k8s_agent_sg_https_ingress" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.k8s_agent_sg.id
}

resource "aws_security_group_rule" "k8s_agent_sg_self_ingress" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [aws_vpc.k8s_vpc.cidr_block]
  security_group_id = aws_security_group.k8s_agent_sg.id
}

resource "aws_iam_role" "k8s_agent_iam_role" {
  name = "k8s_agent_role-${random_string.random_append.result}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
    Name                                        = "k8s_agent_role"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "KubernetesCluster"                         = var.cluster_name
  }
}

resource "aws_iam_policy" "k8s_agent_aws_iam_policy" {
  name        = "k8s-agent-aws-iam-policy"
  path        = "/"
  description = "K8S Master IAM AWS Policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:DescribeInstances",
        "ec2:DescribeRegions",
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:GetRepositoryPolicy",
        "ecr:DescribeRepositories",
        "ecr:ListImages",
        "ecr:BatchGetImage"
      ],
      "Effect": "Allow",
      "Resource": ["*"]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "k8s_agent_aws_iam_attach" {
  role       = aws_iam_role.k8s_agent_iam_role.name
  policy_arn = aws_iam_policy.k8s_agent_aws_iam_policy.arn
}

resource "aws_iam_instance_profile" "k8s_agent_iam_profile" {
  name = "k8s-agent-iam-profile-${random_string.random_append.result}"
  role = aws_iam_role.k8s_agent_iam_role.name
}

resource "aws_instance" "k8s_agent_node" {
  count = var.k3s_agent_count

  ami           = var.amis[var.region][var.os].ami
  instance_type = var.k3s_agent_size
  subnet_id     = aws_subnet.k8s_public_subnet_2.id
  key_name      = "${var.tfuser}-keypair"

  root_block_device {
    volume_type = "standard"
    volume_size = 20
  }

  vpc_security_group_ids = [aws_security_group.k8s_agent_sg.id]

  iam_instance_profile = aws_iam_instance_profile.k8s_agent_iam_profile.name

  tags = {
    Name                                        = "${var.tfuser}_agent_node_${count.index}"
    Owner                                       = var.tfuser
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "KubernetesCluster"                         = var.cluster_name
  }
}

#####################
# CONTROL PLANE ELB #
#####################

resource "aws_elb" "k8s_cp_elb" {
  name = "k8s-cp-elb-${random_string.random_append.result}"

  subnets = [aws_subnet.k8s_public_subnet_1.id, aws_subnet.k8s_public_subnet_2.id]

  instances = aws_instance.k8s_master_node.*.id

  listener {
    instance_port     = 6443
    instance_protocol = "tcp"
    lb_port           = 6443
    lb_protocol       = "tcp"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:6443"
    interval            = 30
  }

  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name                                        = "k8s-cp-elb"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "KubernetesCluster"                         = var.cluster_name
  }

  security_groups = [aws_security_group.k8s_cp_sg.id]
}
