# Providers
provider "alicloud" {
  # Configure provider if needed
}

provider "alicloud" {
  alias  = "use2"
  # Configure provider for use2 region
}

provider "alicloud" {
  alias  = "usw2"
  # Configure provider for usw2 region
}

provider "alicloud" {
  alias  = "beijing"
  # Configure provider for beijing region
}

provider "alicloud" {
  alias  = "hangzhou"
  # Configure provider for hangzhou region
}

provider "alicloud" {
  alias  = "shanghai"
  # Configure provider for shanghai region
}

# Variables
variable "create_networking" {
  type    = bool
  default = true
}

variable "create_uhs_seed_generator" {
  type    = bool
  default = true
}

variable "create_opensearch" {
  type    = bool
  default = true
}

variable "test_controller_launch_type" {
  type    = string
  default = "ECS"
}

variable "test_controller_cpu" {
  type    = number
  default = 2
}

variable "test_controller_memory" {
  type    = number
  default = 4096
}

variable "test_controller_health_check_grace_period_seconds" {
  type    = number
  default = 300
}

variable "transaction_processor_repo_url" {
  type    = string
  default = ""
}

variable "transaction_processor_main_branch" {
  type    = string
  default = "main"
}

variable "transaction_processor_github_access_token" {
  type    = string
  default = ""
}

variable "uhs_seed_generator_max_vcpus" {
  type    = number
  default = 4
}

variable "uhs_seed_generator_job_vcpu" {
  type    = number
  default = 2
}

variable "uhs_seed_generator_job_memory" {
  type    = number
  default = 4096
}

variable "uhs_seed_generator_batch_job_timeout" {
  type    = number
  default = 60
}

variable "base_domain" {
  type    = string
  default = "example.com"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "resource_tags" {
  type    = map(string)
  default = {}
}

variable "public_subnet_cidr" {
  type    = string
  default = ""
}

variable "private_subnet_cidr" {
  type    = string
  default = ""
}

variable "public_subnet_tags" {
  type    = map(string)
  default = {}
}

variable "private_subnet_tags" {
  type    = map(string)
  default = {}
}

variable "use1_main_network_block" {
  type    = string
  default = ""
}

variable "use2_main_network_block" {
  type    = string
  default = ""
}

variable "usw2_main_network_block" {
  type    = string
  default = ""
}

variable "agent_instance_types" {
  type    = list(string)
  default = []
}

variable "ecs_public_key" {
  type    = string
  default = ""
}

variable "lets_encrypt_email" {
  type    = string
  default = ""
}

variable "cert_arn" {
  type    = string
  default = ""
}

variable "opensearch_master_user_name" {
  type    = string
  default = ""
}

variable "opensearch_master_user_password" {
  type    = string
  default = ""
}

variable "opensearch_route53_record_ttl" {
  type    = number
  default = 300
}

variable "opensearch_engine_version" {
  type    = string
  default = "7.10"
}

variable "opensearch_instance_type" {
  type    = string
  default = "elasticsearch7.x.large"
}

variable "opensearch_instance_count" {
  type    = number
  default = 2
}

variable "opensearch_ebs_volume_type" {
  type    = string
  default = "gp2"
}

variable "opensearch_ebs_volume_size" {
  type    = number
  default = 50
}

variable "fire_hose_buffering_interval" {
  type    = number
  default = 300
}

variable "fire_hose_index_rotation_period" {
  type    = string
  default = "OneDay"
}

variable "test_controller_github_repo" {
  type    = string
  default = ""
}

variable "test_controller_github_repo_owner" {
  type    = string
  default = ""
}

variable "test_controller_github_repo_branch" {
  type    = string
  default = "main"
}

variable "test_controller_github_access_token" {
  type    = string
  default = ""
}

variable "test_controller_node_container_build_image" {
  type    = string
  default = ""
}

variable "test_controller_golang_container_build_image" {
  type    = string
  default = ""
}

variable "test_controller_app_container_base_image" {
  type    = string
  default = ""
}

variable "create_certbot_lambda" {
  type    = bool
  default = false
}

variable "uhs_seed_generator_image_repo" {
  type    = string
  default = ""
}

variable "binaries_oss_bucket_name" {
  type    = string
  default = ""
}

variable "test_controller_service_name" {
  type    = string
  default = ""
}

variable "certs_efs_id" {
  type    = string
  default = ""
}

variable "testruns_efs_id" {
  type    = string
  default = ""
}

variable "binaries_efs_id" {
  type    = string
  default = ""
}

variable "hosted_zone_id" {
  type    = string
  default = ""
}

variable "lambda_build_in_docker" {
  type    = bool
  default = false
}

variable "test_controller_image_repo" {
  type    = string
  default = ""
}

variable "test_controller_service_name" {
  type    = string
  default = ""
}

variable "vpc_id_use1" {
  type    = string
  default = ""
}

variable "vpc_id_use2" {
  type    = string
  default = ""
}

variable "vpc_id_usw2" {
  type    = string
  default = ""
}

variable "public_subnets_use1" {
  type    = list(string)
  default = []
}

variable "public_subnets_use2" {
  type    = list(string)
  default = []
}

variable "public_subnets_usw2" {
  type    = list(string)
  default = []
}

variable "private_subnets_use1" {
  type    = list(string)
  default = []
}

variable "private_subnets_use2" {
  type    = list(string)
  default = []
}

variable "private_subnets_usw2" {
  type    = list(string)
  default = []
}

variable "route_tables_use1" {
  type    = list(string)
  default = []
}

variable "route_tables_use2" {
  type    = list(string)
  default = []
}

variable "route_tables_usw2" {
  type    = list(string)
  default = []
}

variable "vpc_azs_use1" {
  type    = list(string)
  default = []
}

variable "vpc_azs_use2" {
  type    = list(string)
  default = []
}

variable "vpc_azs_usw2" {
  type    = list(string)
  default = []
}

variable "oss_interface_endpoint_use1" {
  type    = string
  default = ""
}

variable "oss_interface_endpoint_use2" {
  type    = string
  default = ""
}

variable "oss_interface_endpoint_usw2" {
  type    = string
  default = ""
}

variable "domain_name" {
  type    = string
  default = ""
}

variable "uhs_seed_generator_job_name" {
  type    = string
  default = ""
}

variable "uhs_seed_generator_job_definition_arn" {
  type    = string
  default = ""
}

variable "uhs_seed_generator_job_queue_arn" {
  type    = string
  default = ""
}

variable "certbot_lambda_build_in_docker" {
  type    = bool
  default = false
}

# Data Sources
data "alicloud_availability_zones" "use1" {
  count = var.create_networking ? 1 : 0
}

data "alicloud_availability_zones" "use2" {
  count    = var.create_networking ? 1 : 0
  provider = alicloud.use2
}

data "alicloud_availability_zones" "usw2" {
  count    = var.create_networking ? 1 : 0
  provider = alicloud.usw2
}

data "alicloud_caller_identity" "current" {}

data "alicloud_region" "current" {}

# VPC Modules
module "vpc" {
  count = var.create_networking ? 1 : 0

  source  = "terraform-alicloud-modules/vpc/alicloud"
  version = "1.0.0"

  name                   = local.name
  cidr                   = var.vpc_cidr
  availability_zones     = data.alicloud_availability_zones.use1.names
  enable_dns_support     = true
  enable_dns_hostnames   = true
  resource_group_id      = var.resource_group_id
  tags                   = var.resource_tags
}

# ECS Instances
module "test_controller" {
  source  = "terraform-alicloud-modules/ecs/alicloud"
  version = "1.0.0"

  instance_type       = var.test_controller_launch_type
  cpu                 = var.test_controller_cpu
  memory              = var.test_controller_memory
  image_id            = var.test_controller_image_repo
  security_group_ids  = [module.security_group.id]
  vpc_id              = module.vpc.vpc_id
  subnet_id           = module.vpc.public_subnet_ids[0]
  key_name             = var.ecs_public_key
  tags                = var.resource_tags
  provider            = alicloud.use1
}

# OpenSearch
module "opensearch" {
  source  = "terraform-alicloud-modules/opensearch/alicloud"
  version = "1.0.0"

  domain_name                  = var.domain_name
  instance_type                = var.opensearch_instance_type
  instance_count               = var.opensearch_instance_count
  ebs_volume_size              = var.opensearch_ebs_volume_size
  ebs_volume_type              = var.opensearch_ebs_volume_type
  engine_version               = var.opensearch_engine_version
  master_user_name             = var.opensearch_master_user_name
  master_user_password         = var.opensearch_master_user_password
  route53_record_ttl           = var.opensearch_route53_record_ttl
  resource_group_id            = var.resource_group_id
  tags                         = var.resource_tags
}

# Networking Resources
module "networking" {
  count = var.create_networking ? 1 : 0

  source  = "terraform-alicloud-modules/networking/alicloud"
  version = "1.0.0"

  vpc_id                  = module.vpc.vpc_id
  public_subnet_cidr      = var.public_subnet_cidr
  private_subnet_cidr     = var.private_subnet_cidr
  public_subnet_tags      = var.public_subnet_tags
  private_subnet_tags     = var.private_subnet_tags
  route_tables            = module.vpc.route_tables
  availability_zones      = data.alicloud_availability_zones.use1.names
}

# Certbot Lambda
module "certbot_lambda" {
  source  = "terraform-alicloud-modules/lambda/alicloud"
  version = "1.0.0"

  create = var.create_certbot_lambda

  function_name = "certbot"
  runtime       = "python3.8"
  handler       = "index.handler"
  role_arn      = module.lambda_execution_role.arn
  source_code_hash = filebase64sha256("certbot.zip")
  provider      = alicloud.use1
}
