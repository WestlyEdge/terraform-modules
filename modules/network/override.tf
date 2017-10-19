
# Temporarily open internet access in private vpc so we can ssh to instances
resource "aws_route" "private_nat_route" {
  gateway_id        = "${module.vpc.igw}"
}