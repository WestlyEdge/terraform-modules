
# Temporarily open internet access in private vpc so we can ssh to instances
# You'll receive an error on terraform apply, so you'll need to taint this resource first
resource "aws_route" "private_nat_route" {
  count                   = "${length(var.private_subnet_cidrs)}"
  route_table_id          = "${element(module.private_subnet.route_table_ids, count.index)}"
  gateway_id              = "${module.vpc.igw}"
  destination_cidr_block  = "${var.destination_cidr_block}"
}