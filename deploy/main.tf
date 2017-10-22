provider "aws" {
    region = "${var.region}"
}

variable "region" {
    type = "string"
}

# Variables
variable "image_tag" {
    type = "string"
    default = "latest"
}

variable "image_name" {
    type = "string"
    default = "csv_processor"
}

variable "vpc_id" {
  type    = "string"
}

variable "security_group_ids" {
  type    = "list"
}


data "aws_subnet_ids" "subnets" {
  vpc_id = "${var.vpc_id}"
}
