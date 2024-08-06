# VPC IDs
variable "vpc_id_use1" {
  description = "VPC ID for region us-east-1"
  type        = string
}

variable "vpc_id_use2" {
  description = "VPC ID for region us-east-2"
  type        = string
}

variable "vpc_id_usw2" {
  description = "VPC ID for region us-west-2"
  type        = string
}

# Subnets
variable "public_subnets_use1" {
  description = "Public subnets for region us-east-1"
  type        = list(string)
}

variable "public_subnets_use2" {
  description = "Public subnets for region us-east-2"
  type        = list(string)
}

variable "public_subnets_usw2" {
  description = "Public subnets for region us-west-2"
  type        = list(string)
}

variable "private_subnets_use1" {
  description = "Private subnets for region us-east-1"
  type        = list(string)
}

variable "private_subnets_use2" {
  description = "Private subnets for region us-east-2"
  type        = list(string)
}

variable "private_subnets_usw2" {
  description = "Private subnets for region us-west-2"
  type        = list(string)
}

# EC2
variable "ec2_public_key" {
  description = "Public key for EC2 instances"
  type        = string
}

variable "agent_instance_types" {
  description = "Instance types for the test controller agents"
  type        = list(string)
}

# Base Domain and DNS
variable "base_domain" {
  description = "Base domain for Route 53 DNS"
  type        = string
}

variable "create_networking" {
  description = "Whether to create networking resources"
  type        = bool
  default     = true
}

# Environment
variable "environment" {
  description = "Environment tag for resources"
  type        = string
}

# Test Controller
variable "test_controller_launch_type" {
  description = "Launch type for test controller"
  type        = string
}

variable "test_controller_cpu" {
  description = "CPU allocation for the test controller"
  type        = string
}

variable "test_controller_memory" {
  description = "Memory allocation for the test controller"
  type        = string
}

variable "test_controller_health_check_grace_period_seconds" {
  description = "Health check grace period for the test controller"
  type        = number
}

variable "transaction_processor_repo_url" {
  description = "Repository URL for the transaction processor"
  type        = string
}

variable "transaction_processor_main_branch" {
  description = "Main branch for the transaction processor repository"
  type        = string
}

variable "transaction_processor_github_access_token" {
  description = "GitHub access token for the transaction processor repository"
  type        = string
}

variable "lambda_build_in_docker" {
  description = "Whether to build Lambda function in Docker"
  type        = bool
}

# UHS Seed Generator
variable "uhs_seed_generator_max_vcpus" {
  description = "Maximum vCPUs for UHS seed generator"
  type        = number
}

variable "uhs_seed_generator_job_vcpu" {
  description = "vCPUs for UHS seed generator job"
  type        = number
}

variable "uhs_seed_generator_job_memory" {
  description = "Memory for UHS seed generator job"
  type        = number
}

variable "uhs_seed_generator_batch_job_timeout" {
  description = "Batch job timeout for UHS seed generator"
  type        = number
}

# Test Controller Deploy
variable "test_controller_github_repo" {
  description = "GitHub repository for the test controller"
  type        = string
}

variable "test_controller_github_repo_owner" {
  description = "Owner of the GitHub repository for the test controller"
  type        = string
}

variable "test_controller_github_repo_branch" {
  description = "Branch of the GitHub repository for the test controller"
  type        = string
}

variable "test_controller_github_access_token" {
  description = "Access token for the GitHub repository of the test controller"
  type        = string
}

variable "test_controller_node_container_build_image" {
  description = "Build image for the Node container of the test controller"
  type        = string
}

variable "test_controller_golang_container_build_image" {
  description = "Build image for the Golang container of the test controller"
  type        = string
}

variable "test_controller_app_container_base_image" {
  description = "Base image for the app container of the test controller"
  type        = string
}

# OpenSearch
variable "create_opensearch" {
  description = "Whether to create OpenSearch resources"
  type        = bool
}

variable "opensearch_master_user_name" {
  description = "Master user name for OpenSearch"
  type        = string
}

variable "opensearch_master_user_password" {
  description = "Master user password for OpenSearch"
  type        = string
}

variable "opensearch_route53_record_ttl" {
  description = "TTL for Route 53 record of OpenSearch"
  type        = number
}

variable "opensearch_engine_version" {
  description = "OpenSearch engine version"
  type        = string
}

variable "opensearch_instance_type" {
  description = "Instance type for OpenSearch"
  type        = string
}

variable "opensearch_instance_count" {
  description = "Instance count for OpenSearch"
  type        = number
}

variable "opensearch_ebs_volume_type" {
  description = "EBS volume type for OpenSearch"
  type        = string
}

variable "opensearch_ebs_volume_size" {
  description = "EBS volume size for OpenSearch"
  type        = number
}

variable "fire_hose_buffering_interval" {
  description = "Buffering interval for Firehose"
  type        = string
}

variable "fire_hose_index_rotation_period" {
  description = "Index rotation period for Firehose"
  type        = string
}

# S3 Endpoints
variable "s3_interface_endpoint_use1" {
  description = "S3 interface endpoint for region us-east-1"
  type        = string
}

variable "s3_interface_endpoint_use2" {
  description = "S3 interface endpoint for region us-east-2"
  type        = string
}

variable "s3_interface_endpoint_usw2" {
  description = "S3 interface endpoint for region us-west-2"
  type        = string
}

# Certificate
variable "cert_arn" {
  description = "Certificate ARN for OpenSearch custom endpoint"
  type        = string
}

variable "create_certbot_lambda" {
  description = "Whether to create Certbot Lambda function"
  type        = bool
}

variable "lets_encrypt_email" {
  description = "Email address for Let's Encrypt"
  type        = string
}
