output "default_alb_target_group" {
  value = "${module.alb.default_alb_target_group}"
}

output "ecs_cluster_arn" {
  value = "${aws_ecs_cluster.cluster.id}"
}
