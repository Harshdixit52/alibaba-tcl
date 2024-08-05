locals {
  name = "test-results"
  tags = var.tags
}

###################
### Elasticsearch ###
###################
resource "alicloud_elasticsearch_domain" "this" {
  domain_name        = "${var.environment}-${local.name}"
  version            = var.elasticsearch_engine_version
  instance_type      = var.elasticsearch_instance_type
  instance_count     = var.elasticsearch_instance_count
  disk_type          = var.elasticsearch_disk_type
  disk_size          = var.elasticsearch_disk_size

  # Define access control settings
  access_control {
    master_user_name     = var.master_user_name
    master_user_password = var.master_user_password
  }

  # Define the log publishing options (if available in Alibaba Cloud)
  log_publishing_options {
    # Example: Replace with available options in Alibaba Cloud
    # Uncomment and configure if needed
    # cloudwatch_log_group_arn = alicloud_log_logstore.this.arn
    # log_type                 = "INDEX_SLOW_LOGS"
  }

  # Define tags
  tags = local.tags
}

# Elasticsearch service-linked role
# Alibaba Cloud may not require a service-linked role like AWS, adjust accordingly

# Access policy
resource "alicloud_elasticsearch_domain_policy" "this" {
  domain_name = alicloud_elasticsearch_domain.this.domain_name

  access_policies = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = "es:*"
        Principal = "*"
        Resource  = "${alicloud_elasticsearch_domain.this.arn}/*"
      }
    ]
  })
}

# CNAME for custom Elasticsearch endpoint
resource "alicloud_dns_record" "this" {
  zone_id = var.hosted_zone_id
  name    = "${local.name}.${var.dns_base_domain}"
  type    = "CNAME"
  ttl     = var.route53_record_ttl
  value   = alicloud_elasticsearch_domain.this.endpoint
}

################
### Firehose ###
################
resource "alicloud_logstore" "firehose" {
  name            = "${var.environment}-${local.name}"
  project          = alicloud_log_project.this.name
  ttl              = 7
  shard_count      = 2
  auto_split      = true
}

resource "alicloud_log_project" "this" {
  name = "${var.environment}-${local.name}-log-project"

  tags = local.tags
}

# Example for S3 bucket in Alibaba Cloud (Object Storage Service)
resource "alicloud_oss_bucket" "this" {
  bucket = "${data.alicloud_caller_identity.current.account_id}-firehose-backup"
  force_destroy = true

  tags = local.tags
}
