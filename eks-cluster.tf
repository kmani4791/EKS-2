module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = ">= 18.26.2"
  cluster_name    = local.cluster_name
  cluster_version = "1.22"

  vpc_id  = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_encryption_config = [{
    provider_key_arn = "arn:aws:kms:us-east-1:241144442165:key/4898b82e-77ff-480b-b730-e20c0cb13aeb"
    resources        = ["secrets"]
  }]
  eks_managed_node_group_defaults = [
    {
      name                          = "worker-group-1"
      instance_type                 = "t2.small"
      additional_userdata           = "echo foo bar"
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
      asg_desired_capacity          = 2

    },
    {
      name                          = "worker-group-2"
      instance_type                 = "t2.medium"
      additional_userdata           = "echo foo bar"
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_two.id]
      asg_desired_capacity          = 1
    },
  ]
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}
