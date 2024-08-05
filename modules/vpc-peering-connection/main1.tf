data "alicloud_vpc" "requester" {
  id = var.requester_vpc_id
}

data "alicloud_vpc" "accepter" {
  id = var.accepter_vpc_id
}

data "alicloud_region" "requester" {}

data "alicloud_region" "accepter" {}

# Requester's side of the connection.
resource "alicloud_vpc_peering_connection" "requester" {
  vpc_id      = var.requester_vpc_id
  peer_vpc_id = var.accepter_vpc_id

  tags = {
    Name = "VPC Peering - Requester"
  }
}

# Accepter's side of the connection.
resource "alicloud_vpc_peering_connection_accepter" "accepter" {
  vpc_peering_connection_id = alicloud_vpc_peering_connection.requester.id
  auto_accept               = true

  tags = {
    Name = "VPC Peering - Accepter"
  }
}

# Route for requester's side
resource "alicloud_route_entry" "requester" {
  count              = length(var.requester_route_tables)
  destination_cidr   = data.alicloud_vpc.accepter.cidr_block
  route_table_id     = var.requester_route_tables[count.index]
  next_hop_type      = "VPC_PEERING"
  next_hop_id        = alicloud_vpc_peering_connection.requester.id
}

# Route for accepter's side
resource "alicloud_route_entry" "accepter" {
  count              = length(var.accepter_route_tables)
  destination_cidr   = data.alicloud_vpc.requester.cidr_block
  route_table_id     = var.accepter_route_tables[count.index]
  next_hop_type      = "VPC_PEERING"
  next_hop_id        = alicloud_vpc_peering_connection.requester.id
}
