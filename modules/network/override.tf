
# Temporarily open internet access in private vpc so we can ssh to instances
resource "aws_route" "private_nat_route_debug_mode" {
  count                   = "${length(var.private_subnet_cidrs)}"
  route_table_id          = "${element(module.private_subnet.route_table_ids, count.index)}"
  gateway_id              = "${module.vpc.igw}"
  destination_cidr_block  = "${var.destination_cidr_block}"
}