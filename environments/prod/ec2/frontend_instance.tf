module "prod_frontend" {
  source = "../../../modules/terraform-aws-ec2-instance"

  name                   = "frontend"
  instance_count         = 2
  ami                    = "ami-06fb5332e8e3e577a"
  instance_type          = "t3a.medium"
  key_name               = "topdup-prod"
  user_data              = base64encode(local.user_data)
  root_block_device = [
    {
      volume_size           = 20
      delete_on_termination = true
    }
  ]

  ebs_block_device = [
    {
      device_name = "/dev/sdf"
      volume_type = "gp2"
      volume_size = 100
    }
  ]

  disable_api_termination     = true
  vpc_security_group_ids      = tolist([module.prod_frontend_secgroup.this_security_group_id])
  subnet_ids                  = data.terraform_remote_state.prod_vpc.outputs.prod_vpc_public_subnets

  tags = {
    Name        = "topdup-frontend"
    Terraform   = "true"
    Environment = "topdup-prod"
    Function    = "frontend"
  }
}

module "prod_frontend_secgroup" {
  source  = "../../../modules/terraform-aws-security-group"

  name        = "frontend_secgroup"
  description = "Security group for Database Ec2 CiCd"
  vpc_id      = data.terraform_remote_state.prod_vpc.outputs.prod_vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "all-icmp", "https-443-tcp"]
  egress_rules        = ["all-all"]
}
