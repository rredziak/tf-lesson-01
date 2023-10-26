/* 
variable "vpcs" {
  type = map(string)
}
*/

variable "region" {
  default     = "eu-north-1"
  description = "Region name to create resources."
  nullable    = false
  type        = string
}

variable "networks_per_az" {
  default     = 2
  description = "Number of networks per availability zone"
  nullable    = false
  type        = number
}

variable "base_name" {
  default     = "ProjectX"
  description = "Project basename"
  nullable    = false
  type        = string
}

variable "subnet_prefix" {
  description = "Default number of bits to add to vpc prefix, when subnets are calculated"
  default     = 8
  nullable    = false
  type        = number
}

variable "vpc_cidr" {
  default     = "10.0.0.0/16"
  description = "Address space to alocate for vpc"
  nullable    = false
  type        = string
  validation {
    condition     = regex("[\\d\\.]+/(\\d+)", var.vpc_cidr).0 >= 16
    error_message = "You cannot declare bigger IPv4 VPC than /16."
  }
}

variable "default_security_groups" {
  default = {
    "default_sg_linux" = {
      "description" = "Default Linux SG"
      "rules" = {
        "ingress" = [
          {
            "description" = "Default 22/tcp",
            "from_port"   = 22,
            "to_port"     = 22,
            "protocol"    = "tcp",
            "cidr_blocks" = ["0.0.0.0/0"],
            "ipv6_cidr_blocks" = [],
            "prefix_list_ids" = [],
            "security_groups" = [],
            "self" = null
          },
          {
            "description" = "Default all from self",
            "from_port"   = 22,
            "to_port"     = 22,
            "protocol"    = "tcp",
            "cidr_blocks" = [],
            "ipv6_cidr_blocks" = [],
            "prefix_list_ids" = [],
            "security_groups" = [],
            "self"        = true
          }
        ],
        "egress" = [
          {
            "type"        = "egress",
            "description" = "Default outbound traffic",
            "from_port"   = 0,
            "to_port"     = 0,
            "protocol"    = "-1",
            "cidr_blocks" = ["0.0.0.0/0"],
            "ipv6_cidr_blocks" = [],
            "prefix_list_ids" = [],
            "security_groups" = [],
            "self" = null
          }
        ]
      }
    }
  }
}

variable "project_tags" {
  type = map(string)
}
