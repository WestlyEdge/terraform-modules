resource "aws_vpc" "vpc" {
  cidr_block           = "${var.cidr}"
  enable_dns_hostnames = true

  lifecycle {
    prevent_destroy = true
  }

  tags {
    Name        = "${var.vpc_name}"
    Environment = "${var.environment}"
  }
}

resource "aws_internet_gateway" "vpc" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name        = "internet-gateway-${var.vpc_name}"
    Environment = "${var.environment}"
  }
}
