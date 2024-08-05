# Data source for Alibaba Cloud DNS Zone
data "alicloud_dns_zone" "base_domain" {
  name = var.dns_base_domain
}

# SSL Certificate
resource "alicloud_ssl_certificate" "domain_cert" {
  name             = var.dns_base_domain
  domain           = var.dns_base_domain
  subject_alt_names = ["*.${var.dns_base_domain}"]
  # You need to manually upload the certificate and private key
  # or use other methods to create the SSL certificate
}

# DNS Record for certificate validation (assuming DNS validation)
resource "alicloud_dns_record" "domain_cert_validation_dns" {
  name    = tolist(alicloud_ssl_certificate.domain_cert.domain_validation_options)[0].resource_record_name
  type    = tolist(alicloud_ssl_certificate.domain_cert.domain_validation_options)[0].resource_record_type
  zone_id = data.alicloud_dns_zone.base_domain.id
  value   = tolist(alicloud_ssl_certificate.domain_cert.domain_validation_options)[0].resource_record_value
  ttl     = 60
}

# In Alibaba Cloud, you typically use the "alicloud_ssl_certificate" resource to handle certificate creation,
# and it might require manual steps or different methods to fully manage the certificate validation.
# The SSL certificate validation might involve a different approach based on Alibaba Cloud's services and processes.

