
variable "region" {
  default = "us-east-2"
}

variable "AMI" {

  default = "ami-03d64741867e7bb94"
}

variable "environment" {
  type = map
  default = {
    dev = "dev" 
    stg = "stg"
    prd = "prd"
  }
}


variable "PATH_TO_PRIVATE_KEY" {
  default = "mykey"
  }

variable "PATH_TO_PUBLIC_KEY"{
  default = "mykey.pub"
  }

variable "INSTANCE_USERNAME" {
  default = "ec2-user"
 }

variable "instance_type" { 
  default = "t2.micro" 
}

variable "key_name" {
  default = "mykey.pem.pub" 
}

variable "vpc-cidr" {
  default = "10.0.0.0/16"
}

variable "azs" {
  type = list
  default = ["us-east-2a", "us-east-2b" , "us-east-2c"]
}

variable "public-subnets" {
  type = list
  default = ["10.0.1.0/24", "10.0.7.0/24" , "10.0.3.0/24"]
}

variable "private-subnets" {
  type = list
  default = ["10.0.4.0/24" , "10.0.5.0/24" , "10.0.6.0/24" ]
}
variable "account_name" {
  default = "lanru2001"
}

variable "github_org" {
  default = "lanru2001"
}

variable "github_token" {
}

variable "project" {
	default = "terraform-codepipeline-project"
}

variable "app" {
	default = "terraform-codepipeline-app"
}

variable "account_id" {

}

variable "docker_build_image" {
  default = "Amazon Linux 2"
}

variable "repository_branch" {
  description = "Repository branch to connect to"
  default     = "github.com/lanru2001/aws-cicd-pipeline-project02/edit/main"
}

variable "repository_owner" {
  description = "GitHub repository owner"
  default     = "lanru2001"
}

variable "repository_name" {
  description = "GitHub repository name"
  default     = "https://github.com/lanru2001/aws-cicd-pipeline-project02/edit/main"
}

variable "group_name" {
	default = "ec2_deployment"
}
