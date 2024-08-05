locals {
  name = "uhs_seed_generator"
  seeder_workspace = "seeder-workspace"
}

data "alicloud_region" "current" {}

data "alicloud_account" "current" {}

data "alicloud_vpc" "this" {
  vpc_id = var.vpc_id
}

resource "alicloud_cr_repo" "this" {
  name       = local.name
  visibility = "PRIVATE"

  tags = var.tags
}

resource "alicloud_batch_compute_environment" "this" {
  name = local.name

  compute_resources {
    max_vcpus = var.max_vcpus

    security_group_ids = [
      module.batch_security_group.this_security_group_id
    ]

    subnets = var.private_subnets

    instance_type = "ecs.g6.large"
  }

  service_role = alicloud_ram_role.batch_service_role.id
}

module "batch_security_group" {
  source  = "terraform-alicloud-modules/security-group/alicloud"
  version = "3.1.0"

  name   = "batch-compute"
  vpc_id = var.vpc_id

  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]

  tags = var.tags
}

resource "alicloud_batch_job_queue" "this" {
  name                 = local.name
  state                = "ENABLED"
  priority             = 1
  compute_environments = [alicloud_batch_compute_environment.this.id]
}

resource "alicloud_batch_job_definition" "this" {
  name                 = local.name
  type                 = "Container"
  container_properties = jsonencode({
    "image": "${alicloud_cr_repo.this.repo_namespace}/${local.name}:latest",
    "instanceType": "ecs.g6.large",
    "resourceRequirements": [
      {"type": "VCPU", "value": var.job_vcpu},
      {"type": "MEMORY", "value": var.job_memory}
    ],
    "environment": [
      {
        "name": "BINARIES_OSS_BUCKET",
        "value": var.binaries_oss_bucket
      },
      {
        "name": "SEEDER_WORKSPACE",
        "value": "/mnt/${local.seeder_workspace}"
      }
    ],
    "logConfiguration": {
      "logDriver": "aliyunlogs",
      "options": {
        "aliyunlogs-project": "batch-log-${local.name}",
        "aliyunlogs-region": data.alicloud_region.current.name
      }
    },
    "volumes": [
      {
        "name": "${local.seeder_workspace}",
        "efsVolumeConfiguration": {
          "fileSystemId": "${alicloud_nas_file_system.seeder_workspace.id}",
          "transitEncryption": "DISABLED"
        }
      }
    ],
    "executionRoleArn": alicloud_ram_role.task_execution_role.arn,
    "jobRoleArn": alicloud_ram_role.batch_job_role.arn
  })

  timeout {
    attempt_duration_seconds = var.batch_job_timeout
  }
}

resource "alicloud_log_project" "batch_logs" {
  name       = "batch-log-${local.name}"
  description = "Log project for batch job ${local.name}"
}

resource "alicloud_nas_file_system" "seeder_workspace" {
  description = "${local.name}-${local.seeder_workspace}"
  zone_id     = data.alicloud_vpc.this.vswitches[0].zone_id

  tags = merge(
    {
      Name = "${local.name}-${local.seeder_workspace}"
    },
    var.tags
  )
}

resource "alicloud_nas_mount_target" "seeder_workspace" {
  file_system_id = alicloud_nas_file_system.seeder_workspace.id
  network_type   = "VPC"
  vpc_id         = var.vpc_id
  vswitch_id     = var.private_subnets[0]

  tags = var.tags
}

resource "alicloud_ram_role" "batch_service_role" {
  name       = "batch-service-role"
  statements = [
    {
      effect    = "Allow"
      action    = ["ecs:RunTask"]
      resource  = "*"
      condition = {}
    },
    {
      effect    = "Allow"
      action    = ["log:CreateLogStream", "log:PutLogEvents"]
      resource  = "*"
      condition = {}
    }
  ]
  assume_role_policy = data.alicloud_ram_assume_role_policy_document.batch_service_role.json
}

resource "alicloud_ram_role" "task_execution_role" {
  name       = "batch-task-execution-role"
  statements = [
    {
      effect    = "Allow"
      action    = ["oss:PutObject", "oss:GetObject"]
      resource  = "*"
      condition = {}
    },
    {
      effect    = "Allow"
      action    = ["log:CreateLogStream", "log:PutLogEvents"]
      resource  = "*"
      condition = {}
    }
  ]
  assume_role_policy = data.alicloud_ram_assume_role_policy_document.task_execution_role.json
}

data "alicloud_ram_assume_role_policy_document" "batch_service_role" {
  statement {
    actions   = ["sts:AssumeRole"]
    principal = {
      type        = "Service"
      identifiers = ["ecs.aliyuncs.com"]
    }
  }
}

data "alicloud_ram_assume_role_policy_document" "task_execution_role" {
  statement {
    actions   = ["sts:AssumeRole"]
    principal = {
      type        = "Service"
      identifiers = ["ecs.aliyuncs.com"]
    }
  }
}

resource "alicloud_ram_role" "batch_job_role" {
  name       = "batch-job-role"
  statements = [
    {
      effect    = "Allow"
      action    = ["oss:PutObject", "oss:GetObject"]
      resource  = "*"
      condition = {}
    },
    {
      effect    = "Allow"
      action    = ["log:CreateLogStream", "log:PutLogEvents"]
      resource  = "*"
      condition = {}
    }
  ]
  assume_role_policy = data.alicloud_ram_assume_role_policy_document.batch_job_role.json
}

data "alicloud_ram_assume_role_policy_document" "batch_job_role" {
  statement {
    actions   = ["sts:AssumeRole"]
    principal = {
      type        = "Service"
      identifiers = ["ecs.aliyuncs.com"]
    }
  }
}
