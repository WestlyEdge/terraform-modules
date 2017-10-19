

# Temporarily add public ip so we can ssh to ecs hosts
resource "aws_launch_configuration" "launch" {
  name = "lc-${var.cluster_name}-debug-mode"
  associate_public_ip_address = true

  lifecycle {
    create_before_destroy = true
  }
}

# Temporarily add this rule so we can ssh to ecs hosts
resource "aws_security_group_rule" "public-ssh-access" {
  type                      = "ingress"
  from_port                 = 22
  to_port                   = 22
  protocol                  = "TCP"
  cidr_blocks               = ["0.0.0.0/0"]
  security_group_id         = "${aws_security_group.instance.id}"
}
