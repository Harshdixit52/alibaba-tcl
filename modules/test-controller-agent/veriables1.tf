# Variables for Alibaba Cloud ECS Instance Management

variable "vpc_id" {
  description = "The VPC ID where the ECS instances will be launched."
  type        = string
  default     = ""
}

variable "public_subnets" {
  description = "A list of public subnet IDs within the VPC."
  type        = list(string)
  default     = []
}

variable "private_subnets" {
  description = "A list of private subnet IDs within the VPC."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  default     = {}
}

variable "public_key" {
  description = "The SSH public key to use for the ECS instances."
  type        = string
}

variable "binaries_oss_bucket" {
  description = "The OSS bucket where binaries are stored."
  type        = string
}

variable "outputs_oss_bucket" {
  description = "The OSS bucket where outputs are saved."
  type        = string
}

variable "outputs_oss_bucket_arn" {
  description = "The OSS bucket ARN where outputs are saved."
  type        = string
}

variable "oss_interface_endpoint" {
  description = "DNS record used to route OSS traffic through OSS VPC interface endpoint."
  type        = string
  default     = ""
}

variable "controller_endpoint" {
  description = "The test controller endpoint where agents report."
  type        = string
}

variable "controller_port" {
  description = "The port of the test controller endpoint where agents report."
  type        = string
}

variable "log_group" {
  description = "The CloudMonitor log group to use in the CloudMonitor agent configuration."
  type        = string
}

variable "instance_types" {
  description = "A list of ECS instance types used in agent launch configurations."
  type        = list(string)
  default     = []
}
