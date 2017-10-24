variable "environment" {}
variable "ecs_cluster_arn" {}
variable "cluster_name" {}
variable "desired_capacity" {}
variable "vpc_id" {}
variable "ecs_instance_security_group_id" {}
variable "ecs_instance_role_name" {}
variable "public_subnet_ids" { type = "list" }


