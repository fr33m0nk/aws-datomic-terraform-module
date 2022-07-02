data "aws_subnets" "available" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

data "aws_ami" "datomic_transactor" {
  filter {
    name   = "name"
    values = [var.datomic_transactor_ami_name]
  }
  owners      = [var.datomic_transactor_ami_owner_id]
  most_recent = true
}
