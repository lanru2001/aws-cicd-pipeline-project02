variable "region" {
  type = string
}

variable "AMI" {
  type = string
}

variable "environment" {
  type = map(any)
  default = {
    dev = "dev"
    stg = "stg"
    prd = "prd"
  }
}

variable "PATH_TO_PRIVATE_KEY" {
  type = string
}

variable "PATH_TO_PUBLIC_KEY" {
  type = string
}

variable "INSTANCE_USERNAME" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "key_name" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "azs" {
  type = list
}

variable "public_subnets_cidr" {
  type = list
}

variable "private_subnets_cidr" {
  type = list
}
variable "account_name" {
  type = string
}

variable "github_org" {
  type = string
}

variable "github_token" {
  type = string
}

variable "project" {
  type = string
}

variable "app" {
  type = string
}

variable "account_id" {
  type = string
}

#variable "docker_build_image" {
#  default = "LINUX_CONTAINER"
#}

variable "docker_build_image" {
  type = string
}

variable "repository_branch" {
  type        = string
  description = "Repository branch to connect to"
}

variable "repository_owner" {
  description = "GitHub repository owner"
  type        = string

}

variable "repository_name" {
  description = "GitHub repository name"
  type        = string
}

variable "group_name" {
  type = string
}

variable "create" {
  description = "Whether to create a resource"
  type        = bool
}

variable "name" {
  type = string
}

variable "name_prefix" {
  type = string
}

variable "name_suffix" {
  type = string
}

variable "webhook-secret-token" {
  type = string
}
