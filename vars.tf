variable "projects" {
  description = "Map of projects"

  default = {}
}

variable "region" {
  description = "Region of deployment."
  default = "eu-central-1"
  type = string
}
