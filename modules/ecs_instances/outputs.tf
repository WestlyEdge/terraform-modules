output "ecs_instance_security_group_id" {
  value = "${aws_security_group.instance.id}"
}

output "ecs_instance_asg_name" {
  value = "${aws_autoscaling_group.asg.name}"
}