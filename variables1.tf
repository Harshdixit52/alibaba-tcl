# Flag to create VPCs and related resources
variable "create_networking" {
  type        = bool
  description = "Flag to create VPCs and related resources."
  default     = true
}

# VPC IDs for different regions (required if create_networking is false)
variable "vpc_id_cnbj" {
  type        = string
  description = "ID of VPC in cn-beijing (required if create_networking==false)"
  default     = null
}

variable "vpc_id_cnsh" {
  type        = string
  description = "ID of VPC in cn-shanghai (required if create_networking==false)"
  default     = null
}

variable "vpc_id_cnhz" {
  type        = string
  description = "ID of VPC in cn-hangzhou (required if create_networking==false)"
  default     = null
}

# Public Subnets for different regions (required if create_networking is false)
variable "public_subnets_cnbj" {
  type        = list(string)
  description = "Public subnets in VPC cn-beijing (required if create_networking==false)"
  default     = null
}

variable "public_subnets_cnsh" {
  type        = list(string)
  description = "Public subnets in VPC cn-shanghai (required if create_networking==false)"
  default     = null
}

variable "public_subnets_cnhz" {
  type        = list(string)
  description = "Public subnets in VPC cn-hangzhou (required if create_networking==false)"
  default     = null
}

# Private Subnets for different regions (required if create_networking is false)
variable "private_subnets_cnbj" {
  type        = list(string)
  description = "Private subnets in VPC cn-beijing (required if create_networking==false)"
  default     = null
}

variable "private_subnets_cnsh" {
  type        = list(string)
  description = "Private subnets in VPC cn-shanghai (required if create_networking==false)"
  default     = null
}

variable "private_subnets_cnhz" {
  type        = list(string)
  description = "Private subnets in VPC cn-hangzhou (required if create_networking==false)"
  default     = null
}

# Route Tables for different regions (required if create_networking is false)
variable "route_tables_cnbj" {
  type        = list(string)
  description = "Route tables in VPC cn-beijing (required if create_networking==false)"
  default     = null
}

variable "route_tables_cnsh" {
  type        = list(string)
  description = "Route tables in VPC cn-shanghai (required if create_networking==false)"
  default     = null
}

variable "route_tables_cnhz" {
  type        = list(string)
  description = "Route tables in VPC cn-hangzhou (required if create_networking==false)"
  default     = null
}

# Availability Zones for different regions (required if create_networking is false)
variable "vpc_azs_cnbj" {
  type        = list(string)
  description = "AZs of VPC in cn-beijing (required if create_networking==false)"
  default     = null
}

variable "vpc_azs_cnsh" {
  type        = list(string)
  description = "AZs of VPC in cn-shanghai (required if create_networking==false)"
  default     = null
}

variable "vpc_azs_cnhz" {
  type        = list(string)
  description = "AZs of VPC in cn-hangzhou (required if create_networking==false)"
  default     = null
}

# S3 Endpoint for VPCs (required if create_networking is false)
variable "s3_interface_endpoint_cnbj" {
  type        = string
  description = "S3 endpoint for VPC in cn-beijing (required if create_networking==false)"
  default     = null
}

variable "s3_interface_endpoint_cnsh" {
  type        = string
  description = "S3 endpoint for VPC in cn-shanghai (required if create_networking==false)"
  default     = null
}

variable "s3_interface_endpoint_cnhz" {
  type        = string
  description = "S3 endpoint for VPC in cn-hangzhou (required if create_networking==false)"
  default     = null
}

# CIDR Blocks for different regions
variable "cnbj_main_network_block" {
  type        = string
  description = "Base CIDR block to be used in cn-beijing."
  default     = "10.0.0.0/16"
}

variable "cnsh_main_network_block" {
  type        = string
  description = "Base CIDR block to be used in cn-shanghai."
  default     = "10.10.0.0/16"
}

variable "cnhz_main_network_block" {
  type        = string
  description = "Base CIDR block to be used in cn-hangzhou."
  default     = "10.20.0.0/16"
}

# Subnet Configuration
variable "subnet_prefix_extension" {
  type        = number
  description = "CIDR block bits extension to calculate CIDR blocks of each subnetwork."
  default     = 4
}

variable "public_subnet_tags" {
  type        = map(string)
  description = "Tags associated with public subnets"
  default     = {}
}

variable "private_subnet_tags" {
  type        = map(string)
  description = "Tags associated with private subnets"
  default     = {}
}

variable "zone_offset" {
  type        = number
  description = "CIDR block bits extension offset to calculate Public subnets, avoiding collisions with Private subnets."
  default     = 8
}
# Test Controller
variable "create_certbot_lambda" {
  type        = bool
  description = "Boolean to create the certbot lambda to update the letsencrypt cert for the test controller."
  default     = true
}

variable "lambda_build_in_docker" {
  type        = bool
  description = "Determines whether or not to build certbot lambda function in docker."
  default     = true
}

variable "lets_encrypt_email" {
  type        = string
  description = "Email to associate with let's encrypt certificate"
}

variable "test_controller_github_repo" {
  description = "The Github repo base name"
  type        = string
  default     = "opencbdc-tctl"
}

variable "test_controller_github_repo_owner" {
  description = "The Github repo owner"
  type        = string
  default     = "mit-dci"
}

variable "test_controller_github_repo_branch" {
  description = "The repo branch to use for the Test Controller deployment pipeline."
  type        = string
  default     = "trunk"
}

variable "test_controller_github_access_token" {
  description = "Access token for cloning test controller repo"
  type        = string
}

variable "test_controller_node_container_build_image" {
  type        = string
  description = "An optional custom container build image for test controller Nodejs dependencies"
  default     = "node:14"
}

variable "test_controller_golang_container_build_image" {
  type        = string
  description = "An optional custom container build image for test controller Golang dependencies"
  default     = "golang:1.16"
}

variable "test_controller_app_container_base_image" {
  type        = string
  description = "An optional custom container base image for the test controller and related services"
  default     = "ubuntu:20.04"
}

variable "test_controller_launch_type" {
  description = "The ECS task launch type to run the test controller."
  type        = string
  default     = "CLOUD"
}

variable "test_controller_cpu" {
  description = "The ECS task CPU"
  type        = string
  default     = "4096"
}

variable "test_controller_memory" {
  description = "The ECS task memory"
  type        = string
  default     = "30720"
}

variable "test_controller_health_check_grace_period_seconds" {
  description = "The ECS service health check grace period in seconds"
  type        = number
  default     = 300
}

variable "transaction_processor_repo_url" {
  description = "Transaction repo cloned by the test controller for load generation logic"
  type        = string
  default     = "https://github.com/mit-dci/opencbdc-tx.git"
}

variable "transaction_processor_main_branch" {
  type        = string
  description = "Main branch of transaction repo"
  default     = "trunk"
}

variable "transaction_processor_github_access_token" {
  type        = string
  description = "Access token for the transaction repo if permissions are required"
  default     = ""
}

variable "cluster_instance_type" {
  type        = string
  description = "If test controller launch type is ECS, the instance size to use."
  default     = "ecs.c6g.large"
}

# OpenSearch
variable "create_opensearch" {
  type        = bool
  description = "Boolean to create OpenSearch domain and related resources"
  default     = false
}

variable "opensearch_master_user_name" {
  type        = string
  description = "Master username of OpenSearch user"
  default     = "admin"
}

variable "opensearch_master_user_password" {
  type        = string
  description = "Master password of OpenSearch user"
  default     = ""
  sensitive   = true
}

variable "opensearch_route53_record_ttl" {
  type        = string
  description = "TTL for CNAME record of OpenSearch domain"
  default     = "600"
}

variable "opensearch_engine_version" {
  type        = string
  description = "The engine version to use for the OpenSearch domain"
  default     = "OpenSearch_1.3"
}

variable "opensearch_instance_type" {
  type        = string
  description = "Instance type used for OpenSearch cluster"
  default     = "elasticsearch.r6g.large"
}

variable "opensearch_instance_count" {
  type        = string
  description = "Number of instances to include in OpenSearch domain"
  default     = "1"
}

variable "opensearch_ebs_volume_type" {
  type        = string
  description = "Type of EBS volume to back OpenSearch domain"
  default     = "gp2"
}

variable "opensearch_ebs_volume_size" {
  type        = string
  description = "Size of EBS volume to back OpenSearch domain"
  default     = "10"
}

variable "fire_hose_buffering_interval" {
  type        = number
  description = "Interval time between sending Fire Hose buffer data to OpenSearch"
  default     = 60
}

variable "fire_hose_index_rotation_period" {
  type        = string
  description = "The OpenSearch index rotation period. Index rotation appends a timestamp to the IndexName to facilitate expiration of old data."
  default     = "OneDay"
}

# Seed Generator
variable "create_uhs_seed_generator" {
  type        = bool
  description = "Determines whether or not to create UHS seed generator resources"
  default     = true
}

variable "uhs_seed_generator_max_vcpus" {
  description = "Max vCPUs allocatable to the seed generator environment"
  type        = string
  default     = "50"
}

variable "uhs_seed_generator_job_vcpu" {
  description = "vCPUs required for a seed generator batch job"
  type        = string
  default     = "4"
}

variable "uhs_seed_generator_job_memory" {
  description = "Memory required for a seed generator batch job"
  type        = string
  default     = "8192"
}

variable "uhs_seed_generator_batch_job_timeout" {
  description = "Memory required for a seed generator batch job"
  type        = string
  default     = 1209600 # 14 days, max for Fargate
}

# Test Controller Agents
variable "agent_instance_types" {
  type        = list(string)
  description = "The instance types used in agent launch templates."
  default     = [
    "ecs.c6n.large",
    "ecs.c6n.xlarge",
    "ecs.c6n.2xlarge",
    "ecs.c6n.4xlarge"
  ]
}

# Tags
variable "environment" {
  type        = string
  description = "Tag to indicate environment name of each infrastructure object."
}

variable "resource_tags" {
  type        = map(string)
  description = "Tags to set for all resources"
  default     = {}
}
