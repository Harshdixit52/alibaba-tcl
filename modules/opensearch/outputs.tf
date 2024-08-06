output "elasticsearch_endpoint" {
  value       = alicloud_dns_record.this.fqdn
  description = "The Elasticsearch endpoint."
}
