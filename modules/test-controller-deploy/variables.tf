variable "cluster_name" {
  description = "The ECS cluster name"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID"
  type        = string
  default     = ""
}

variable "private_subnets" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "test_controller_oss_repo" {
  description = "The OSS repo for the test controller"
  type        = string
}

variable "uhs_seed_generator_oss_repo" {
  description = "The OSS repo for the UHS seed generator"
  type        = string
}

variable "test_controller_ecs_service_name" {
  description = "The ECS Service name for the test controller"
  type        = string
}

variable "node_container_build_image" {
  description = "An optional custom container build image for Node.js dependencies"
  type        = string
}

variable "golang_container_build_image" {
  description = "An optional custom container build image for Golang dependencies"
  type        = string
}

variable "app_container_base_image" {
  description = "An optional custom container base image for the test controller and related services"
  type        = string
}

variable "binaries_oss_bucket" {
  description = "The OSS bucket where agent binaries should be published by the pipeline"
  type        = string
}

variable "github_repo" {
  description = "The Github repo base name"
  type        = string
}

variable "github_repo_owner" {
  description = "The Github repo owner"
  type        = string
}

variable "github_repo_branch" {
  description = "The Github repo branch"
  type        = string
}

variable "github_access_token" {
  description = "Name of OAuth token for GitHub private repo"
  type        = string
}

variable "tags" {
  description = "Tags to set for all resources"
  type        = map(string)
  default     = {}
}

variable "oss_interface_endpoint" {
  description = "DNS record used to route OSS traffic through OSS VPC interface endpoint"
  type        = string
  default     = ""
}
