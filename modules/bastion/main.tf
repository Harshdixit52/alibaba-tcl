locals {
  name                   = "bastion"
  certs_mount_path       = "/opt/nas-mounts/certs"
  testruns_mount_path    = "/opt/nas-mounts/testruns"
  binaries_mount_path    = "/opt/nas-mounts/binaries"
  tags = {
    Owner       = "terraform"
    Environment = var.environment
  }
}

# Create the ECS security group
resource "alicloud_security_group" "bastion" {
  name        = "${local.name}-sg"
  vpc_id      = var.vpc_id
  description = "Security group for bastion host"

  // Allow all incoming traffic
  ingress {
    ip_protocol = "-1"
    port_range  = "0/0"
    source_cidr_ip = "0.0.0.0/0"
  }

  // Allow all outgoing traffic
  egress {
    ip_protocol = "-1"
    port_range  = "0/0"
    dest_cidr_ip = "0.0.0.0/0"
  }

  tags = local.tags
}

# ECS Key Pair
resource "alicloud_key_pair" "bastion" {
  key_name   = local.name
  public_key = var.public_key

  tags = local.tags
}

# Lookup Ubuntu AMI ID
data "alicloud_images" "bastion" {
  owners = ["099720109477"] # Canonical (Ubuntu)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}

# Allocate an Elastic IP
resource "alicloud_eip" "bastion" {
  instance_id = alicloud_instance.bastion.id

  tags = merge(
    {
      Name = local.name
    },
    local.tags
  )
}

# Create the ECS instance
resource "alicloud_instance" "bastion" {
  instance_name = local.name
  instance_type = "ecs.t5-lc2m1.nano" # Example instance type, adjust as needed
  image_id      = data.alicloud_images.bastion.id
  security_groups = [alicloud_security_group.bastion.id]
  key_name       = alicloud_key_pair.bastion.key_name
  internet_charge_type = "PayByTraffic"
  internet_max_bandwidth_out = 1

  // EIP Association
  eip {
    allocation_id = alicloud_eip.bastion.id
  }

  // Mount NAS
  system_disk_category = "cloud_efficiency"
  system_disk_size = 40

  tags = local.tags

  // User data
  user_data = templatefile(
    "${path.module}/templates/init.tpl",
    {
      "CERTS_MOUNT_PATH"       = local.certs_mount_path
      "TESTRUNS_MOUNT_PATH"    = local.testruns_mount_path
      "BINARIES_MOUNT_PATH"    = local.binaries_mount_path
      "CERTS_NAS_ID"           = var.certs_efs_id
      "TESTRUNS_NAS_ID"        = var.testruns_efs_id
      "BINARIES_NAS_ID"        = var.binaries_efs_id
      "REGION"                 = data.alicloud_region.current.id
      "EIP_ASSOCIATION_ID"     = alicloud_eip.bastion.id
    }
  )
}

# Create A record for the EIP
resource "alicloud_dns_record" "bastion" {
  zone_id = var.dns_base_domain
  name    = "${local.name}.${var.dns_base_domain}"
  type    = "A"
  ttl     = 600
  value   = alicloud_eip.bastion.ip_address
}
