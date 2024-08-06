# Define local variables
locals {
  name            = "test-controller"
  agent_port      = "8081"
  ui_port         = "443"
  ui_port_wo_cert = "8443"
  tags            = var.tags
}

# Get the current AWS region
data "aws_region" "current" {}

# ECS Task Definition
resource "aws_ecs_task_definition" "task" {
  family                   = local.name
  requires_compatibilities = [var.launch_type]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = <<DEFINITION
[
  {
    "essential": true,
    "image": "${aws_ecr_repository.app.repository_url}:latest",
    "name": "${local.name}",
    "environment": [
      {
        "name": "BINARIES_S3_BUCKET",
        "value": "${var.binaries_s3_bucket}"
      },
      {
        "name": "OUTPUTS_S3_BUCKET",
        "value": "${var.outputs_s3_bucket}"
      },
      {
        "name": "S3_INTERFACE_ENDPOINT",
        "value": "${var.s3_interface_endpoint}"
      },
      {
        "name": "S3_INTERFACE_REGION",
        "value": "us-east-1"
      },
      {
        "name": "AWS_DEFAULT_REGION",
        "value": "${data.aws_region.current.name}"
      },
      {
        "name": "HTTPS_PORT",
        "value": "${local.ui_port}"
      },
      {
        "name": "HTTPS_WITHOUT_CLIENT_CERT_PORT",
        "value": "${local.ui_port_wo_cert}"
      },
      {
        "name": "PORT",
        "value": "${local.agent_port}"
      },
      {
        "name": "TRANSACTION_PROCESSOR_REPO_URL",
        "value" : "${var.transaction_processor_repo_url}"
      },
      {
        "name": "TRANSACTION_PROCESSOR_MAIN_BRANCH",
        "value" : "${var.transaction_processor_main_branch}"
      },
      {
        "name": "UHS_SEEDER_BATCH_JOB",
        "value": "${var.uhs_seed_generator_job_name}"
      }
    ],
    %{if var.transaction_processor_github_access_token != ""}
    "secrets": [
      {
        "name": "TRANSACTION_PROCESSOR_ACCESS_TOKEN",
        "valueFrom": "${aws_ssm_parameter.transaction_processor_github_access_token[0].arn}"
      }
    ],
    %{ else }%{ endif }
    "portMappings": [
      {
        "containerPort": ${tonumber(local.ui_port)}
      },
      {
        "containerPort": ${tonumber(local.ui_port_wo_cert)}
      },
      {
        "containerPort": ${tonumber(local.agent_port)}
      }
    ],
    "ulimits": [
        {
          "name": "nofile",
          "softLimit": 32768,
          "hardLimit": 32768
        }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "${data.aws_region.current.name}",
        "awslogs-group": "${aws_cloudwatch_log_group.app.name}",
        "awslogs-stream-prefix": "${local.name}"
      }
    },
    "mountPoints": [
      {
        "containerPath": "/app/data/certs/",
        "sourceVolume": "certs"
      },
      {
        "containerPath": "/app/data/testruns/",
        "sourceVolume": "testruns"
      },
      {
        "containerPath": "/app/data/binaries/",
        "sourceVolume": "binaries"
      }
    ]
  }
]
DEFINITION

  volume {
    name = "certs"
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.certs.id
      transit_encryption = "ENABLED"
    }
  }

  volume {
    name = "testruns"
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.testruns.id
      transit_encryption = "ENABLED"
    }
  }

  volume {
    name = "binaries"
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.binaries.id
      transit_encryption = "ENABLED"
    }
  }

  tags = local.tags
}

# ECS Task Execution Role Policy Document
data "aws_iam_policy_document" "ecs_task_execution_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# ECS Task Execution Role Policy Actions Document
data "aws_iam_policy_document" "ecs_task_execution_role_policy_actions" {
  statement {
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "*",
    ]
  }

  dynamic "statement" {
    for_each = try(aws_ssm_parameter.transaction_processor_github_access_token, [])

    content {
      actions = [
        "ssm:GetParameters",
      ]

      resources = [
        statement.value.arn
      ]
    }
  }

}

# ECS Task Execution IAM Role
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${local.name}_ecs_task_execution_role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role_policy.json

  tags = local.tags
}

# ECS Task Execution IAM Policy
resource "aws_iam_role_policy" "ecs_task_execution_role_policy" {
  name   = "${local.name}_ecs_task_execution_role_policy"
  role   = aws_iam_role.ecs_task_execution_role.id
  policy = data.aws_iam_policy_document.ecs_task_execution_role_policy_actions.json
}

# ECS Task Role Policy Document
data "aws_iam_policy_document" "ecs_task_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# ECS Task Role Policy Actions Document
data "aws_iam_policy_document" "ecs_task_role_policy_actions" {
  statement {
    actions = [
      "ec2:*",
      "servicequotas:Get*",
      "servicequotas:List*",
      "iam:PassRole"
    ]

    resources = [
      "*"
    ]
  }
}

# ECS Task Role S3 Write Policy Actions Document
data "aws_iam_policy_document" "ecs_task_role_policy_s3_write_actions" {
  statement {
    actions = [
      "s3:PutObject"
    ]

    resources = [
      var.binaries_s3_bucket_arn,
      "${var.binaries_s3_bucket_arn}/*"
    ]
  }
}

data "aws_iam_policy_document" "ecs_task_role_policy_batch_submit_jobs_actions" {
  statement {
    actions = [
      "batch:SubmitJob"
    ]

    resources = [
      var.uhs_seed_generator_job_definiton_arn,
      var.uhs_seed_generator_job_queue_arn
    ]
  }

  statement {
    actions = [
      "batch:DescribeJobs"
    ]

    resources = ["*"]
  }
}

# ECS Task IAM Role
resource "aws_iam_role" "ecs_task_role" {
  name               = "${local.name}_ecs_task_role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_role_policy.json

  tags = local.tags
}

# ECS Task IAM Policy
resource "aws_iam_role_policy" "ecs_task_role_policy" {
  name   = "${local.name}_ecs_task_role_policy"
  role   = aws_iam_role.ecs_task_role.id
  policy = data.aws_iam_policy_document.ecs_task_role_policy_actions.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_s3_read_only" {
  role       = aws_iam_role.ecs_task_role.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_role_policy" "ecs_task_role_s3_write_policy" {
  name   = "${local.name}_ecs_task_role_s3_write_policy"
  role   = aws_iam_role.ecs_task_role.id
  policy = data.aws_iam_policy_document.ecs_task_role_policy_s3_write_actions.json
}

resource "aws_iam_role_policy" "ecs_task_role_batch_submit_jobs_policy" {
  name   = "${local.name}_ecs_task_role_batch_submit_jobs_policy"
  role   = aws_iam_role.ecs_task_role.id
  policy = data.aws_iam_policy_document.ecs_task_role_policy_batch_submit_jobs_actions.json
}

# Cloudwatch Logs Group for ECS Fargate Task logs
resource "aws_cloudwatch_log_group" "app" {
  name              = "/${local.name}"
  retention_in_days = 1

  tags = local.tags
}

# EFS Security Group
module "efs_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"
  name    = "${local.name}_efs_sg"
  vpc_id  = var.vpc_id
  ingress = [
    {
      from_port   = 2049
      to_port     = 2049
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
  ]
  egress = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    },
  ]
}

# EFS File System for certs
resource "aws_efs_file_system" "certs" {
  creation_token = "${local.name}-certs"
  tags           = local.tags
}

# EFS Mount Target for certs
resource "aws_efs_mount_target" "certs" {
  file_system_id  = aws_efs_file_system.certs.id
  subnet_id       = var.subnet_id
  security_groups = [module.efs_security_group.id]
}

# EFS File System for test runs
resource "aws_efs_file_system" "testruns" {
  creation_token = "${local.name}-testruns"
  tags           = local.tags
}

# EFS Mount Target for test runs
resource "aws_efs_mount_target" "testruns" {
  file_system_id  = aws_efs_file_system.testruns.id
  subnet_id       = var.subnet_id
  security_groups = [module.efs_security_group.id]
}

# EFS File System for binaries
resource "aws_efs_file_system" "binaries" {
  creation_token = "${local.name}-binaries"
  tags           = local.tags
}

# EFS Mount Target for binaries
resource "aws_efs_mount_target" "binaries" {
  file_system_id  = aws_efs_file_system.binaries.id
  subnet_id       = var.subnet_id
  security_groups = [module.efs_security_group.id]
}

# ECR Repository
resource "aws_ecr_repository" "app" {
  name = local.name

  tags = local.tags
}

# Security Group for ECS Service
module "ecs_service_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"
  name    = "${local.name}_ecs_service_sg"
  vpc_id  = var.vpc_id
  ingress = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  egress = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

# Load Balancer
module "ui_nlb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "5.13.0"
  name    = "${local.name}-ui-nlb"
  internal = false
  load_balancer_type = "network"
  security_groups     = [module.ecs_service_sg.id]
  subnets             = var.subnets
  enable_deletion_protection = false
  enable_cross_zone_load_balancing = true
  tags = local.tags
}

# Listener for NLB
resource "aws_lb_listener" "ui_nlb_listener" {
  load_balancer_arn = module.ui_nlb.arn
  port              = 443
  protocol          = "TLS"
  default_action {
    type = "forward"
    target_group_arn = module.ui_target_group.arn
  }

  ssl_policy = "ELBSecurityPolicy-TLS-1-2-2017-01"

  certificate_arn = var.certificate_arn
}

# Target Group for NLB
module "ui_target_group" {
  source  = "terraform-aws-modules/alb/aws"
  version = "5.13.0"
  name    = "${local.name}-ui-tg"
  port    = 443
  protocol = "TLS"
  vpc_id  = var.vpc_id
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name               = "${local.name}_lambda_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json

  tags = local.tags
}

# Lambda Function
resource "aws_lambda_function" "certbot_lambda" {
  filename         = "certbot_lambda.zip"
  function_name    = "${local.name}_certbot"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "python3.8"
  source_code_hash = filebase64sha256("certbot_lambda.zip")

  environment {
    variables = {
      AWS_REGION = data.aws_region.current.name
    }
  }

  tags = local.tags
}

# DNS Records for NLB
resource "aws_route53_record" "ui_nlb" {
  zone_id = var.zone_id
  name    = "${local.name}.example.com"
  type    = "A"
  alias {
    name                   = module.ui_nlb.dns_name
    zone_id                = module.ui_nlb.zone_id
    evaluate_target_health = true
  }
}

# Apply configuration
output "ecs_task_definition_arn" {
  value = aws_ecs_task_definition.task.arn
}

output "ecr_repository_url" {
  value = aws_ecr_repository.app.repository_url
}

output "efs_file_system_certs_id" {
  value = aws_efs_file_system.certs.id
}

output "efs_file_system_testruns_id" {
  value = aws_efs_file_system.testruns.id
}

output "efs_file_system_binaries_id" {
  value = aws_efs_file_system.binaries.id
}
