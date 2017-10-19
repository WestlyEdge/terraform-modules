
#------------------------------------------------------------------------------
# Applying this module helps when you need to temporarily ssh into ecs hosts
# TODO: this does not work yet without some manual intervention
#------------------------------------------------------------------------------

# add public ip to ecs instance launch configuration
resource "aws_launch_configuration" "launch" {
  name = "lc-${var.cluster_name}-debug-mode"
  associate_public_ip_address = true

}

# temporarily add this rule so we can ssh to ecs instances
resource "aws_security_group_rule" "public-ssh-access" {
  type                      = "ingress"
  from_port                 = 22
  to_port                   = 22
  protocol                  = "TCP"
  cidr_blocks               = ["0.0.0.0/0"]
  security_group_id         = "${var.security_group_id}"
}

# temporarily open internet access in private vpc so we can ssh to ecs instances
resource "aws_route" "private_nat_route" {
  gateway_id = "${var.vpc_internet_gateway_id}"
}
