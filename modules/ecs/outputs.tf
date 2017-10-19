
output "ecs_cluster_arn" {
  value = "${aws_ecs_cluster.cluster.id}"
}

output "ecs_instance_role_name" {
  value = "${aws_iam_role.ecs_instance_role.name}"
}

output "ecs_instance_asg_name" {
  value = "${module.ecs_instances.ecs_instance_asg_name}"
}

output "network_vpc_id" {
  value = "${module.network.vpc_id}"
}

output "network_public_subnet_ids" {
  value = "${module.network.public_subnet_ids}"
}

output "ecs_instance_security_group_id" {
  value = "${module.ecs_instances.ecs_instance_security_group_id}"
}

output "vpc_internet_gateway_id" {
  value = "${module.network.vpc_internet_gateway_id}"
}
