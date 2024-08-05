#################
### Endpoints ###
#################

data "alicloud_route_tables" "this" {
  vpc_id = var.vpc_id
}

module "vpc_endpoints" {
  source = "terraform-alicloud-modules/vpc/alicloud//modules/vpc-endpoints"

  vpc_id             = var.vpc_id
  security_group_ids = [module.vpc_endpoint_security_group.this_security_group_id]

  endpoints = {
    oss = {
      service             = "oss"
      tags                = merge({ Name = "oss-interface" }, var.tags)
      subnet_ids          = var.private_subnets
    },
    # For ECS pulls from Container Registry
    oss_gateway = {
      service          = "oss"
      service_type     = "Gateway"
      route_table_ids  = data.alicloud_route_tables.this.ids
      tags             = merge({ Name = "oss-gateway" }, var.tags)
    },
    log_service = {
      service             = "log"
      private_dns_enabled = true
      subnet_ids          = var.private_subnets
      tags                = {Name = "log-service"}
    },
    cr_docker_registry = {
      service             = "cr.docker.registry"
      private_dns_enabled = true
      subnet_ids          = var.private_subnets
      tags                = merge({Name = "cr-docker-registry"}, var.tags)
    },
    cr_api = {
      service             = "cr.api"
      private_dns_enabled = true
      subnet_ids          = var.private_subnets
      tags                = merge({Name = "cr-api"}, var.tags)
    },
    ecs = {
      service             = "ecs"
      private_dns_enabled = true
      subnet_ids          = var.private_subnets
      tags                = merge({Name = "ecs"}, var.tags)
    },
    ecs_metrics = {
      service             = "ecs-metrics"
      private_dns_enabled = true
      subnet_ids          = var.private_subnets
      tags                = merge({Name = "ecs-metrics"}, var.tags)
    },
    ecs_agent = {
      service             = "ecs-agent"
      private_dns_enabled = true
      subnet_ids          = var.private_subnets
      tags                = merge({Name = "ecs-agent"}, var.tags)
    }
  }
}

######################
### Security Group ###
######################

module "vpc_endpoint_security_group" {
  source  = "terraform-alicloud-modules/security-group/alicloud"
  version = "1.0.0"

  name   = "vpc-endpoint-sg"
  vpc_id = var.vpc_id

  ingress_with_cidr_blocks = [
    {
      rule        = "all-all"
      cidr_blocks = join(",", var.vpc_cidr_blocks)
    }
  ]

  egress_with_cidr_blocks = [
    {
      rule        = "all-all"
      cidr_blocks = join(",", var.vpc_cidr_blocks)
    }
  ]

  tags = var.tags
}

