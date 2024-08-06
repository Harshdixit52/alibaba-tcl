output "cert_id" {
  value       = alicloud_ssl_certificate.domain_cert.id
  description = "The SSL certificate ID"
}

output "hosted_zone_id" {
  value = data.alicloud_dns_zone.base_domain.id
  description = "Alibaba Cloud DNS zone ID of the base domain"
}

output "name_servers" {
  value = data.alicloud_dns_zone.base_domain.name_servers
  description = "Name servers associated with the Alibaba Cloud DNS base domain"
}
