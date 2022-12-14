module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.23.0.0/16"

  azs             = ["ap-northeast-1a"]
  private_subnets = ["10.23.1.0/24"]
  public_subnets  = ["10.23.2.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = false

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}