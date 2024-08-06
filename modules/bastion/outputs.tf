output "bastion_endpoint" {
    description = "The bastion endpoint where users can access via an SSH connection"
    value = alicloud_dns_record.bastion.fqdn
}
