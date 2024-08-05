variable "dns_base_domain" {
  type        = string
  description = "DNS Zone name to be used for SSL certificate creation."
}

variable "tags" {
  type        = map(string)
  description = "Tags to set for all resources."
  default     = {}
}
