# ALB implementation that can be used to connect ECS instances to it

resource "aws_alb_target_group" "default" {
  name                 = "${var.alb_name}-target"
  port                 = "${var.port}"
  protocol             = "${var.protocol}"
  vpc_id               = "${var.vpc_id}"
  deregistration_delay = "${var.deregistration_delay}"

  health_check {
    path     = "${var.health_check_path}"
    protocol = "${var.protocol}"
  }

  tags {
    Environment = "${var.environment}"
  }
}

resource "aws_alb" "alb" {
  name            = "${var.alb_name}"
  subnets         = ["${var.public_subnet_ids}"]
  security_groups = ["${aws_security_group.alb.id}"]

  tags {
    Environment = "${var.environment}"
  }
}

resource "aws_alb_listener" "https" {
  load_balancer_arn = "${aws_alb.alb.id}"
  port              = "${var.port}"
  protocol          = "${var.protocol}"

  default_action {
    target_group_arn = "${aws_alb_target_group.default.id}"
    type             = "forward"
  }
}

resource "aws_security_group" "alb" {
  name   = "${var.alb_name}"
  vpc_id = "${var.vpc_id}"
  description = "sec group for ${var.alb_name} load balancer"

  tags {
    Name = "sg-${var.alb_name}"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group_rule" "https_from_anywhere" {
  type              = "ingress"
  from_port         = "${var.port}"
  to_port           = "${var.port}"
  protocol          = "TCP"
  cidr_blocks       = ["${var.allow_cidr_block}"]
  security_group_id = "${aws_security_group.alb.id}"
}

resource "aws_security_group_rule" "outbound_internet_access" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.alb.id}"
}
