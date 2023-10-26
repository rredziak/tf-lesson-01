locals {
  network_list = [
    for el in setproduct(data.aws_availability_zones.aws_azs.names, range(0, var.networks_per_az)) :
    tomap({ "name" = "${el.1}-${substr(el.0, -1, -1)}", new_bits = var.subnet_prefix })
  ]
}

data "aws_availability_zones" "aws_azs" {}


module "subnet_addrs" {
  source = "hashicorp/subnets/cidr"

  base_cidr_block = var.vpc_cidr

  networks = local.network_list
}

resource "aws_vpc" "main" {

  cidr_block = var.vpc_cidr

  tags = merge({
    Name = "${var.base_name}-vpc"
  }, var.project_tags)
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge({
    Name = "${var.base_name}-igw"
  }, var.project_tags)
}

resource "aws_route_table" "default_gw" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge({
    Name = "${var.base_name}-defaut-rtb"
  }, var.project_tags)
}

resource "aws_route_table_association" "default_gw" {
  // for_each = toset(values(aws_subnet.subnet)[*].id)
  count = length(values(aws_subnet.subnet)[*].id)

  route_table_id = aws_route_table.default_gw.id
  subnet_id      = element(values(aws_subnet.subnet)[*].id, count.index)
}

resource "aws_subnet" "subnet" {
  for_each = module.subnet_addrs.network_cidr_blocks

  vpc_id = aws_vpc.main.id

  cidr_block = each.value

  tags = merge({
    Name = "${var.base_name}-subnet-${each.key}"
  }, var.project_tags)
}

resource "aws_security_group" "group" {
  for_each = var.default_security_groups

  description = each.value.description
  name        = "${each.key}-${aws_vpc.main.id}"
  vpc_id      = aws_vpc.main.id

  ingress = [
    for rule in each.value.rules.ingress: rule
  ]
  egress = [
    for rule in each.value.rules.egress: rule 
  ]

  lifecycle {
    create_before_destroy = true
  }

  tags = merge({
    Name = "${var.base_name}-sg-${each.key}-${aws_vpc.main.id}"
  }, var.project_tags)
}

/* 
resource "null_resource" "sgroup-debug" {
  for_each = var.default_security_groups

  provisioner "local-exec" {
    command = "echo $KEY >> debug.txt ; echo $INGRESS >> debug.txt ; echo >> debug.txt"

    environment = {
      KEY = jsonencode(each.key)
      INGRESS = jsonencode([for rule in each.value.rules.ingress : rule])
    }
  }
}
*/
