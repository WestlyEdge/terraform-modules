output "alb_target_group" {
  value = "${module.alb.default_alb_target_group}"
}

output "ecs_cluster_arn" {
  value = "${aws_ecs_cluster.cluster.id}"
}

output "alb_name" {
  value = "${module.alb.alb_name}"
}

output "alb_security_group_id" {
  value = "${module.alb.alb_security_group_id}"
}

output "ecs_instance_security_group_id" {
  value = "${module.ecs_instances.ecs_instance_security_group_id}"
}