locals {
  name        = "hamilton"
  required_tags = {
    Owner       = "terraform"
    Environment = var.environment
  }
  tags = merge(var.resource_tags, local.required_tags)

  # IDs
  vpc_id_use1 = var.create_networking ? module.vpc[0].vpc_id : var.vpc_id_use1
  vpc_id_use2 = var.create_networking ? module.vpc_use2[0].vpc_id : var.vpc_id_use2
  vpc_id_usw2 = var.create_networking ? module.vpc_usw2[0].vpc_id : var.vpc_id_usw2

  # Subnets
  public_subnets_use1 = var.create_networking ? module.vpc[0].public_subnets : var.public_subnets_use1
  public_subnets_use2 = var.create_networking ? module.vpc_use2[0].public_subnets : var.public_subnets_use2
  public_subnets_usw2 = var.create_networking ? module.vpc_usw2[0].public_subnets : var.public_subnets_usw2

  private_subnets_use1 = var.create_networking ? module.vpc[0].private_subnets : var.private_subnets_use1
  private_subnets_use2 = var.create_networking ? module.vpc_use2[0].private_subnets : var.private_subnets_use2
  private_subnets_usw2 = var.create_networking ? module.vpc_usw2[0].private_subnets : var.private_subnets_usw2

  # Route tables
  route_tables_use1 = var.create_networking ? module.vpc[0].route_table_ids : var.route_tables_use1
  route_tables_use2 = var.create_networking ? module.vpc_use2[0].route_table_ids : var.route_tables_use2
  route_tables_usw2 = var.create_networking ? module.vpc_usw2[0].route_table_ids : var.route_tables_usw2

  # Availability Zones
  vpc_azs_use1 = var.create_networking ? module.vpc[0].azs : var.vpc_azs_use1
  vpc_azs_use2 = var.create_networking ? module.vpc_use2[0].azs : var.vpc_azs_use2
  vpc_azs_usw2 = var.create_networking ? module.vpc_usw2[0].azs : var.vpc_azs_usw2

  # VPC endpoints
  s3_interface_endpoint_use1 = var.create_networking ? module.vpc_endpoints_use1[0].s3_interface_endpoint : var.s3_interface_endpoint_use1
  s3_interface_endpoint_use2 = var.create_networking ? module.vpc_endpoints_use2[0].s3_interface_endpoint : var.s3_interface_endpoint_use2
  s3_interface_endpoint_usw2 = var.create_networking ? module.vpc_endpoints_usw2[0].s3_interface_endpoint : var.s3_interface_endpoint_usw2

  # DNS
  domain_name = var.create_networking ? module.route53_dns[0].domain_name : var.domain_name
  cert_id      = var.create_networking ? module.route53_dns[0].cert_id : var.cert_id
}

# Get the current region
data "alicloud_region" "current" {}

# Used for accessing Account ID and ARN
data "alicloud_caller_identity" "current" {}

################################
#### VPCs ######################
################################

# Region: cn-east-1
data "alicloud_availability_zones" "use1" {
  count = var.create_networking ? 1 : 0

  available_zone_ids = []
}

module "vpc" {
  count = var.create_networking ? 1 : 0

  source  = "terraform-alicloud-modules/vpc/alicloud"
  version = "2.0.0"

  name = local.name
  cidr = var.use1_main_network_block
  azs  = data.alicloud_availability_zones.use1[0].ids

  private_subnets = [
    for zone_id in data.alicloud_availability_zones.use1[0].ids :
    cidrsubnet(var.use1_main_network_block, var.subnet_prefix_extension, length(data.alicloud_availability_zones.use1[0].ids) - 1)
  ]

  public_subnets = [
    for zone_id in data.alicloud_availability_zones.use1[0].ids :
    cidrsubnet(var.use1_main_network_block, var.subnet_prefix_extension, length(data.alicloud_availability_zones.use1[0].ids) + var.zone_offset - 1)
  ]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
  enable_dns_hostnames   = true
  public_subnet_tags     = var.public_subnet_tags
  private_subnet_tags    = var.private_subnet_tags

  tags = local.tags
}

# Region: cn-east-2
data "alicloud_availability_zones" "use2" {
  count = var.create_networking ? 1 : 0

  provider = alicloud.use2
}

module "vpc_use2" {
  count = var.create_networking ? 1 : 0

  source  = "terraform-alicloud-modules/vpc/alicloud"
  version = "2.0.0"

  providers = {
    alicloud = alicloud.use2
  }

  name = local.name
  cidr = var.use2_main_network_block
  azs  = data.alicloud_availability_zones.use2[0].ids

  private_subnets = [
    for zone_id in data.alicloud_availability_zones.use2[0].ids :
    cidrsubnet(var.use2_main_network_block, var.subnet_prefix_extension, length(data.alicloud_availability_zones.use2[0].ids) - 1)
  ]

  public_subnets = [
    for zone_id in data.alicloud_availability_zones.use2[0].ids :
    cidrsubnet(var.use2_main_network_block, var.subnet_prefix_extension, length(data.alicloud_availability_zones.use2[0].ids) + var.zone_offset - 1)
  ]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
  enable_dns_hostnames   = true
  public_subnet_tags     = var.public_subnet_tags
  private_subnet_tags    = var.private_subnet_tags

  tags = local.tags
}

# Region: cn-west-1
data "alicloud_availability_zones" "usw2" {
  count = var.create_networking ? 1 : 0

  provider      = alicloud.usw2
}

module "vpc_usw2" {
  count = var.create_networking ? 1 : 0

  source  = "terraform-alicloud-modules/vpc/alicloud"
  version = "2.0.0"

  providers = {
    alicloud = alicloud.usw2
  }

  name = local.name
  cidr = var.usw2_main_network_block
  azs  = data.alicloud_availability_zones.usw2[0].ids

  private_subnets = [
    for zone_id in data.alicloud_availability_zones.usw2[0].ids :
    cidrsubnet(var.usw2_main_network_block, var.subnet_prefix_extension, length(data.alicloud_availability_zones.usw2[0].ids) - 1)
  ]

  public_subnets = [
    for zone_id in data.alicloud_availability_zones.usw2[0].ids :
    cidrsubnet(var.usw2_main_network_block, var.subnet_prefix_extension, length(data.alicloud_availability_zones.usw2[0].ids) + var.zone_offset - 1)
  ]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
  enable_dns_hostnames   = true
  public_subnet_tags     = var.public_subnet_tags
  private_subnet_tags    = var.private_subnet_tags

  tags = local.tags
}

################################
#### VPC Peering Connections ###
################################

# cn-east-1 <-> cn-east-2
module "vpc_peering_connection_use1_use2" {
  count = var.create_networking ? 1 : 0

  source = "./modules/vpc-peering-connection"

  providers = {
    alicloud.requester = alicloud.use1
    alicloud.accepter  = alicloud.use2
  }

  requester_vpc_id       = local.vpc_id_use1
  accepter_vpc_id        = local.vpc_id_use2
  requester_route_tables = local.route_tables_use1
  accepter_route_tables  = local.route_tables_use2
}

# cn-east-2 <-> cn-west-1
module "vpc_peering_connection_use2_usw2" {
  count = var.create_networking ? 1 : 0

  source = "./modules/vpc-peering-connection"

  providers = {
    alicloud.requester = alicloud.use2
    alicloud.accepter  = alicloud.usw2
  }

  requester_vpc_id       = local.vpc_id_use2
  accepter_vpc_id        = local.vpc_id_usw2
  requester_route_tables = local.route_tables_use2
  accepter_route_tables  = local.route_tables_usw2
}
#####################
### VPC Endpoints ###
#####################
module "vpc_endpoints_use1" {
  count = var.create_networking ? 1 : 0

  source = "./modules/vpc-endpoints"  # This module should be adapted for Alibaba Cloud

  providers = {
    alicloud = alicloud.use1
  }

  vpc_id          = local.vpc_id_use1
  public_subnets  = local.public_subnets_use1
  private_subnets = local.private_subnets_use1
  vpc_cidr_blocks = [
    var.use1_main_network_block,
    var.use2_main_network_block,
    var.usw2_main_network_block
  ]

  tags = local.tags
}

module "vpc_endpoints_use2" {
  count = var.create_networking ? 1 : 0

  source = "./modules/vpc-endpoints"  # This module should be adapted for Alibaba Cloud

  providers = {
    alicloud = alicloud.use2
  }

  vpc_id          = local.vpc_id_use2
  public_subnets  = local.public_subnets_use2
  private_subnets = local.private_subnets_use2
  vpc_cidr_blocks = [
    var.use1_main_network_block,
    var.use2_main_network_block,
    var.usw2_main_network_block
  ]

  tags = local.tags
}

module "vpc_endpoints_usw2" {
  count = var.create_networking ? 1 : 0

  source = "./modules/vpc-endpoints"  # This module should be adapted for Alibaba Cloud

  providers = {
    alicloud = alicloud.usw2
  }

  vpc_id          = local.vpc_id_usw2
  public_subnets  = local.public_subnets_usw2
  private_subnets = local.private_subnets_usw2
  vpc_cidr_blocks = [
    var.use1_main_network_block,
    var.use2_main_network_block,
    var.usw2_main_network_block
  ]

  tags = local.tags
}
################################
#### ECS Clusters ##############
################################

# Create RAM Role for ECS
resource "alicloud_ram_role" "ecs" {
  name = "ecsRole"
  assume_role_policy = jsonencode({
    Version = "1",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs.aliyuncs.com"
        }
      }
    ]
  })
}

# Create ECS Cluster
resource "alicloud_cs_cluster" "ecs" {
  name = var.environment
  cluster_type = "Kubernetes"

  # Adjust configuration according to Alibaba Cloud requirements
  tags = local.tags
}

# Create ECS Node Pool
resource "alicloud_cs_node_pool" "ecs" {
  name = "ecs-node-pool"
  cluster_id = alicloud_cs_cluster.ecs.id
  node_pool_type = "MANAGED"

  # Specify instance types, sizes, etc.
  node_instance_types = ["ecs.c6.large"]
  min_node_count = 1
  max_node_count = 2

  tags = local.tags
}
################################
## ECS ECS ASG ################
################################

# Create ECS Instance Profile
resource "alicloud_ram_role_attachment" "ecs" {
  role_name = alicloud_ram_role.ecs.name
  policy_arn = "acs:ram::aws:policy/service-role/AliyunECSFullAccess"
}

# ECS Security Group
resource "alicloud_security_group" "ecs_cluster_security_group" {
  name = "ecs-cluster-sg"
  vpc_id = local.vpc_id_use1

  egress = [
    {
      cidr_ip = "0.0.0.0/0"
      ip_protocol = "ALL"
    }
  ]

  ingress = [
    {
      cidr_ip = join(",",[
        var.use1_main_network_block,
        var.use2_main_network_block,
        var.usw2_main_network_block
      ])
      ip_protocol = "ALL"
    }
  ]

  tags = local.tags
}

# Create ECS Auto Scaling Group
resource "alicloud_autoscaling_group" "ecs_cluster_asg" {
  name = "ecs-cluster-asg"
  launch_configuration = alicloud_launch_configuration.ecs.id
  min_size = 1
  max_size = 2
  desired_capacity = 1
  vpc_id = local.vpc_id_use1
  vpc_zone = local.private_subnets_use1

  tags = [
    {
      key   = "Environment"
      value = var.environment
    },
    {
      key   = "Owner"
      value = "terraform"
    }
  ]
}

# Launch Configuration for ECS
resource "alicloud_launch_configuration" "ecs" {
  name = "ecs-cluster-lc"
  image_id = data.alicloud_images.default.id
  instance_type = var.cluster_instance_type
  security_groups = [alicloud_security_group.ecs_cluster_security_group.id]
  instance_profile = alicloud_ram_role_attachment.ecs.id

  user_data = file("${path.module}/templates/user-data.sh")

  tags = local.tags
}
################################
#### Binary Storage ############
################################

# OSS Bucket
resource "alicloud_oss_bucket" "binaries" {
  bucket = "${data.alicloud_caller_identity.current.account_id}-${data.alicloud_region.current.id}-binaries"
  force_destroy = true
  acl = "private"

  tags = local.tags
}

# OSS Bucket Versioning
resource "alicloud_oss_bucket_versioning" "binaries" {
  bucket = alicloud_oss_bucket.binaries.id
  status = "Enabled"
}

# OSS Bucket Encryption
resource "alicloud_oss_bucket_encryption" "binaries" {
  bucket = alicloud_oss_bucket.binaries.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
################################
#### Test Controller ###########
################################

module "test_controller_service" {
  source = "./modules/test-controller"

  vpc_id                                    = local.vpc_id_use1
  vpc_cidr_blocks                           = [
    var.use1_main_network_block,
    var.use2_main_network_block,
    var.usw2_main_network_block
  ]
  public_subnets                            = local.public_subnets_use1
  private_subnets                           = local.private_subnets_use1
  hosted_zone_id                            = local.hosted_zone_id
  azs                                       = local.vpc_azs_use1
  cluster_id                                = module.ack.ack_cluster_id  # Assume ACK (Alibaba Cloud Kubernetes) for cluster_id
  dns_base_domain                           = var.base_domain
  binaries_oss_bucket                       = alicloud_oss_bucket.binaries.id
  binaries_oss_bucket_arn                   = alicloud_oss_bucket.binaries.arn
  outputs_oss_bucket                        = alicloud_oss_bucket.agent_outputs.id
  create_certbot_lambda                     = var.create_certbot_lambda
  lets_encrypt_email                        = var.lets_encrypt_email
  oss_interface_endpoint                    = local.oss_interface_endpoint_use1
  launch_type                               = var.test_controller_launch_type
  cpu                                       = var.test_controller_cpu
  memory                                    = var.test_controller_memory
  health_check_grace_period_seconds         = var.test_controller_health_check_grace_period_seconds
  transaction_processor_repo_url            = var.transaction_processor_repo_url
  transaction_processor_main_branch         = var.transaction_processor_main_branch
  transaction_processor_github_access_token = var.transaction_processor_github_access_token
  uhs_seed_generator_job_name               = module.uhs_seed_generator[0].job_name
  uhs_seed_generator_job_definition_arn     = module.uhs_seed_generator[0].job_definition_arn
  uhs_seed_generator_job_queue_arn          = module.uhs_seed_generator[0].job_queue_arn
  certbot_lambda_build_in_docker            = var.lambda_build_in_docker

  # Tags
  tags = local.tags
}

module "uhs_seed_generator" {
  source = "./modules/uhs-seed-generator"

  count = var.create_uhs_seed_generator ? 1 : 0

  vpc_id                 = local.vpc_id_use1
  private_subnets        = local.private_subnets_use1
  max_vcpus              = var.uhs_seed_generator_max_vcpus
  job_vcpu               = var.uhs_seed_generator_job_vcpu
  job_memory             = var.uhs_seed_generator_job_memory
  batch_job_timeout      = var.uhs_seed_generator_batch_job_timeout
  binaries_oss_bucket    = alicloud_oss_bucket.binaries.id

  # Tags
  tags                   = local.tags
}

module "opensearch" {
  source = "./modules/opensearch"

  count = var.create_opensearch ? 1 : 0

  dns_base_domain                 = var.base_domain
  hosted_zone_id                  = local.hosted_zone_id
  custom_endpoint_certificate_arn = local.cert_arn
  environment                     = var.environment
  master_user_name                = var.opensearch_master_user_name
  master_user_password            = var.opensearch_master_user_password
  route53_record_ttl              = var.opensearch_route53_record_ttl
  opensearch_engine_version       = var.opensearch_engine_version
  opensearch_instance_type        = var.opensearch_instance_type
  opensearch_instance_count       = var.opensearch_instance_count
  opensearch_ebs_volume_type      = var.opensearch_ebs_volume_type
  opensearch_ebs_volume_size      = var.opensearch_ebs_volume_size
  fire_hose_buffering_interval    = var.fire_hose_buffering_interval
  fire_hose_index_rotation_period = var.fire_hose_index_rotation_period

  # Tags
  tags                       = local.tags
}

################################
#### Test Controller Agents ####
################################

# Region: cn-east-1
resource "alicloud_log_store" "agents_use1" {
  name = "/test-controller-agents-cn-east-1"
  retention = 1
}

module "test_controller_agent_use1" {
  source = "./modules/test-controller-agent"

  providers = {
    alicloud = alicloud.use1
  }

  vpc_id                    = local.vpc_id_use1
  public_subnets            = local.public_subnets_use1
  private_subnets           = local.private_subnets_use1
  public_key                = var.ecs_public_key
  binaries_oss_bucket       = alicloud_oss_bucket.binaries.id
  outputs_oss_bucket        = alicloud_oss_bucket.agent_outputs.id
  outputs_oss_bucket_arn    = alicloud_oss_bucket.agent_outputs.arn
  oss_interface_endpoint    = local.oss_interface_endpoint_use1
  controller_endpoint       = module.test_controller_service.agent_endpoint
  controller_port           = module.test_controller_service.agent_port
  log_store                 = alicloud_log_store.agents_use1.name
  instance_types            = var.agent_instance_types

  # Tags
  tags = local.tags
}

# Region: cn-east-2
resource "alicloud_log_store" "agents_use2" {
  name = "/test-controller-agents-cn-east-2"
  retention = 1
}

module "test_controller_agent_use2" {
  source = "./modules/test-controller-agent"

  providers = {
    alicloud = alicloud.use2
  }

  vpc_id                    = local.vpc_id_use2
  public_subnets            = local.public_subnets_use2
  private_subnets           = local.private_subnets_use2
  public_key                = var.ecs_public_key
  binaries_oss_bucket       = alicloud_oss_bucket.binaries.id
  outputs_oss_bucket        = alicloud_oss_bucket.agent_outputs.id
  outputs_oss_bucket_arn    = alicloud_oss_bucket.agent_outputs.arn
  oss_interface_endpoint    = local.oss_interface_endpoint_use1
  controller_endpoint       = module.test_controller_service.agent_endpoint
  controller_port           = module.test_controller_service.agent_port
  log_store                 = alicloud_log_store.agents_use2.name
  instance_types            = var.agent_instance_types

  # Tags
  tags = local.tags
}

# Region: cn-west-2
resource "alicloud_log_store" "agents_usw2" {
  name = "/test-controller-agents-cn-west-2"
  retention = 1
}

module "test_controller_agent_usw2" {
  source = "./modules/test-controller-agent"

  providers = {
    alicloud = alicloud.usw2
  }

  vpc_id                    = local.vpc_id_usw2
  public_subnets            = local.public_subnets_usw2
  private_subnets           = local.private_subnets_usw2
  public_key                = var.ecs_public_key
  binaries_oss_bucket       = alicloud_oss_bucket.binaries.id
  outputs_oss_bucket        = alicloud_oss_bucket.agent_outputs.id
  outputs_oss_bucket_arn    = alicloud_oss_bucket.agent_outputs.arn
  oss_interface_endpoint    = local.oss_interface_endpoint_use1
  controller_endpoint       = module.test_controller_service.agent_endpoint
  controller_port           = module.test_controller_service.agent_port
  log_store                 = alicloud_log_store.agents_usw2.name
  instance_types            = var.agent_instance_types

  # Tags
  tags = local.tags
}
################################
#### Test Controller Deploy ####
################################

module "test_controller_deploy" {
  source = "./modules/test-controller-deploy"

  vpc_id                           = local.vpc_id_use1
  private_subnets                  = local.private_subnets_use1
  binaries_oss_bucket              = alicloud_oss_bucket.binaries.id
  cluster_name                     = module.ack.ack_cluster_name  # Use ACK (Alibaba Cloud Kubernetes) for cluster_name
  test_controller_image_repo       = module.test_controller_service.image_repo  # Equivalent of ECR
  test_controller_service_name     = module.test_controller_service.service_name  # Equivalent of ECS service
  uhs_seed_generator_image_repo    = module.uhs_seed_generator[0].image_repo  # Equivalent of ECR
  github_repo                      = var.test_controller_github_repo
  github_repo_owner                = var.test_controller_github_repo_owner
  github_repo_branch               = var.test_controller_github_repo_branch
  github_access_token              = var.test_controller_github_access_token
  oss_interface_endpoint           = local.oss_interface_endpoint_use1
  node_container_build_image       = var.test_controller_node_container_build_image
  golang_container_build_image     = var.test_controller_golang_container_build_image
  app_container_base_image         = var.test_controller_app_container_base_image

  # Tags
  tags = local.tags
}
################################
#### Alibaba Cloud DNS #########
################################

module "alibaba_dns" {
  count = var.create_networking ? 1 : 0

  source = "./modules/alibaba_dns"

  dns_base_domain = var.base_domain

  # Tags
  tags = local.tags
}
################################
#### Bastion Host ##############
################################

module "bastion" {
  source = "./modules/bastion"

  vpc_id          = local.vpc_id_use1
  public_subnets  = local.public_subnets_use1
  public_key      = var.ecs_public_key  # Equivalent to EC2 public key
  hosted_zone_id  = local.hosted_zone_id
  certs_nas_id    = module.test_controller_service.certs_nas_id  # Use NAS or similar
  testruns_nas_id = module.test_controller_service.testruns_nas_id  # Use NAS or similar
  binaries_nas_id = module.test_controller_service.binaries_nas_id  # Use NAS or similar
  dns_base_domain = var.base_domain

  # Tags
  environment = var.environment
}
