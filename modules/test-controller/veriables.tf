variable "vpc_id" {
  description = "The VPC id"
  type        = string
  default     = ""
}

variable "vpc_cidr_blocks" {
  description = "A list of VPC CIDR blocks to add to the interface endpoint security group"
  type        = list(string)
  default     = ["10.0.0.0/8"]
}

variable "public_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "private_subnets" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "hosted_zone_id" {
  description = "DNS Zone ID for Alibaba Cloud DNS"
  type        = string
}

variable "azs" {
  description = "A list of availability zones inside the VPC"
  type        = list(string)
  default     = []
}

variable "cluster_id" {
  description = "The ACK cluster ID"
  type        = string
}

variable "launch_type" {
  description = "The ACK task launch type"
  type        = string
}

variable "cpu" {
  description = "The ACK task CPU"
  type        = string
}

variable "memory" {
  description = "The ACK task memory"
  type        = string
}

variable "health_check_grace_period_seconds" {
  description = "The ACK service health check grace period in seconds"
  type        = number
}

variable "tags" {
  description = "Tags to set for all resources"
  type        = map(string)
  default     = {}
}

variable "dns_base_domain" {
  description = "DNS base domain to be used in load balancer CNAME creation."
  type        = string
}

variable "binaries_oss_bucket" {
  description = "The OSS bucket where binaries are stored."
  type        = string
}

variable "outputs_oss_bucket" {
  description = "The OSS bucket where test result outputs are stored."
  type        = string
}

variable "oss_interface_endpoint" {
  description = "DNS record used to route OSS traffic through OSS VPC interface endpoint"
  type        = string
  default     = ""
}

variable "github_repo" {
  description = "The GitHub repo base name"
  type        = string
  default     = "cbdc-test-controller"
}

variable "github_repo_owner" {
  description = "The GitHub repo owner"
  type        = string
  default     = "mit-dci"
}

variable "github_repo_branch" {
  description = "The GitHub repo branch"
  type        = string
  default     = "master"
}

variable "create_certbot_function" {
  description = "Boolean to create the certbot function to update the Let's Encrypt cert for the test controller."
  type        = bool
}

variable "transaction_processor_repo_url" {
  description = "Transaction repo cloned by the test controller for load generation logic"
  type        = string
}

variable "transaction_processor_main_branch" {
  description = "Main branch of transaction repo"
  type        = string
}

variable "transaction_processor_github_access_token" {
  description = "Access token for the transaction repo if permissions are required"
  type        = string
  default     = ""
}

variable "uhs_seed_generator_job_name" {
  description = "Name of batch job used for UHS seed generation"
  type        = string
}

variable "uhs_seed_generator_job_definition_id" {
  description = "ID of UHS seed generator job definition"
  type        = string
}

variable "uhs_seed_generator_job_queue_id" {
  description = "ID of UHS seed generator job queue"
  type        = string
}

variable "lets_encrypt_email" {
  description = "Email to associate with Let's Encrypt certificate"
  type        = string
}

variable "certbot_function_build_in_docker" {
  description = "Determines whether or not to build certbot function in Docker."
  type        = bool
  default     = true
}
