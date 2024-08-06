variable "environment" {
  type        = string
  description = "Alibaba Cloud tag to indicate environment name of each infrastructure object."
}

variable "dns_base_domain" {
  type        = string
  description = "DNS Zone name to be used in Elasticsearch custom endpoint options."
}

variable "hosted_zone_id" {
  type        = string
  description = "DNS zone id of the base domain."
}

variable "custom_endpoint_certificate_id" {
  type        = string
  description = "The ACM cert ID to use with the custom endpoint."
}

variable "master_user_name" {
  type        = string
  description = "Master username of Elasticsearch user."
}

variable "master_user_password" {
  type        = string
  description = "Master password of Elasticsearch user."
  sensitive   = true
}

variable "route53_record_ttl" {
  type        = string
  description = "TTL for CNAME record of Elasticsearch domain."
}

variable "elasticsearch_engine_version" {
  type        = string
  description = "The engine version to use for the Elasticsearch domain."
}

variable "elasticsearch_instance_type" {
  type        = string
  description = "Instance type used for Elasticsearch cluster."
}

variable "elasticsearch_instance_count" {
  type        = string
  description = "Number of instances to include in Elasticsearch domain."
}

variable "elasticsearch_disk_type" {
  type        = string
  description = "Type of disk to back Elasticsearch domain."
}

variable "elasticsearch_disk_size" {
  type        = string
  description = "Size of disk to back Elasticsearch domain."
}

variable "fire_hose_buffering_interval" {
  type        = number
  description = "Interval time between sending Fire Hose buffer data to Elasticsearch."
}

variable "fire_hose_index_rotation_period" {
  type        = string
  description = "The Elasticsearch index rotation period."
}

variable "tags" {
  type        = map(string)
  description = "Tags to set for all resources."
  default     = {}
}
