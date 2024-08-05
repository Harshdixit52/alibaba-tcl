output "oss_interface_endpoint" {
  value       = "https://bucket${trimspace(module.vpc_endpoints.endpoints["oss"]["dns_entry"][0]["dns_name"], "*")}"
  description = "DNS must be specified in order to route traffic through to the OSS interface endpoint"
}
