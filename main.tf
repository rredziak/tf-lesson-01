module "vpc" {
  source = "./vpc"

  for_each = var.projects

  base_name       = each.key
  vpc_cidr        = lookup(each.value, "address_space", null)
  subnet_prefix   = lookup(each.value, "subnet_prefix", null)
  project_tags    = lookup(each.value, "tags", null)
  networks_per_az = lookup(each.value, "networks_per_az", null)
}

