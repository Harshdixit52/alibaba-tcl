locals {
  name = "test-controller-agent"
  tags = var.tags
}

# Data source for Alibaba Cloud region
data "alicloud_region" "current" {}

# Security Group for ECS Instances
resource "alicloud_security_group" "agent_security_group" {
  name        = "agent-instance-sg"
  vpc_id      = var.vpc_id
  description  = "Security group for agent instances"

  ingress {
    ip_protocol = "tcp"
    port_range  = "22/22"
    cidr_ip     = "0.0.0.0/0"
  }

  ingress {
    ip_protocol = "all"
    port_range  = "-1/-1"
    cidr_ip     = "10.0.0.0/8"
  }

  egress {
    ip_protocol = "all"
    port_range  = "-1/-1"
    cidr_ip     = "0.0.0.0/0"
  }

  tags = local.tags
}

# Cloud-init configuration
data "template_file" "cloud_init" {
  template = file("${path.module}/templates/init.tpl")

  vars = {
    REGION                 = data.alicloud_region.current.id
    BINARIES_OSS_BUCKET    = var.binaries_oss_bucket
    OUTPUTS_OSS_BUCKET     = var.outputs_oss_bucket
    OSS_BUCKET_PREFIX      = local.name
    OSS_INTERFACE_ENDPOINT = var.oss_interface_endpoint
    COORDINATOR_HOST       = var.controller_endpoint
    COORDINATOR_PORT       = var.controller_port
  }
}

# Key Pair for ECS Instances
resource "alicloud_key_pair" "agent_key" {
  key_name   = local.name
  public_key = var.public_key

  tags = local.tags
}

# ECS Image (AMI equivalent in Alibaba Cloud)
data "alicloud_images" "agent_image" {
  most_recent = true
  owners      = ["ubuntu"]

  filter {
    name   = "name"
    values = ["ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# ECS Instance Launch Template
resource "alicloud_instance" "agent" {
  count                  = length(var.instance_types)
  instance_type          = var.instance_types[count.index]
  image_id               = data.alicloud_images.agent_image.id
  instance_name          = "${local.name}-${count.index}"
  security_groups        = [alicloud_security_group.agent_security_group.id]
  vpc_id                 = var.vpc_id
  vswitch_id             = var.private_subnets[0]
  key_name               = alicloud_key_pair.agent_key.key_name
  user_data              = data.template_file.cloud_init.rendered
  system_disk_category   = "cloud_ssd"
  system_disk_size       = 100

  tags = merge(
    {
      Name = local.name
    },
    local.tags
  )

  monitor_status = "enable"
}

# RAM Role for ECS Instances
resource "alicloud_ram_role" "agent_role" {
  role_name = "agent-role-${data.alicloud_region.current.id}"

  assume_role_policy = jsonencode({
    "Version": "1",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "ecs.aliyuncs.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })

  tags = local.tags
}

# RAM Policy for ECS Instance Outputs
resource "alicloud_ram_policy" "agent_policy" {
  policy_name = "AgentOutputsPolicy"
  policy_type = "Custom"
  role_name   = alicloud_ram_role.agent_role.role_name

  policy_document = jsonencode({
    "Version": "1",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "oss:PutObject*"
        ],
        "Resource": [
          "${var.outputs_oss_bucket_arn}",
          "${var.outputs_oss_bucket_arn}/*"
        ]
      }
    ]
  })

  tags = local.tags
}

# CloudMonitor configuration parameter
resource "alicloud_ssm_parameter" "cw_agent_config" {
  name  = "CloudMonitor-Config.json"
  type  = "String"
  value = jsonencode({
    "agent": {
      "region": data.alicloud_region.current.id
    },
    "logs": {
      "logs_collected": {
        "files": {
          "collect_list": [
            {
              "file_path": "/var/log/cbdc_agent*.log",
              "log_group_name": var.log_group,
              "log_stream_name": "{instance_id}-${local.name}",
              "timezone": "UTC"
            },
            {
              "file_path": "/var/log/cloud-init-output.log",
              "log_group_name": var.log_group,
              "log_stream_name": "{instance_id}-${local.name}-cloud-init-output",
              "timezone": "UTC"
            }
          ]
        }
      }
    }
  })

  tags = local.tags
}
