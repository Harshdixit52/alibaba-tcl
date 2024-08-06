output "vpc_peering_connection_id" {
  value       = alicloud_vpc_peering_connection.requester.id
  description = "The ID of the VPC peering connection."
}

output "requester_vpc_cidr" {
  value       = data.alicloud_vpc.requester.cidr_block
  description = "The CIDR block of the requester VPC."
}

output "accepter_vpc_cidr" {
  value       = data.alicloud_vpc.accepter.cidr_block
  description = "The CIDR block of the accepter VPC."
}
