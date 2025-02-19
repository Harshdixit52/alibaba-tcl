variable "vpc_id" {
  description = "The VPC id"
  type        = string
  default     = ""
}

variable "private_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "max_vcpus" {
  description = "Max vcpus allocatable to the seed generator environment"
  type        = string
}

variable "job_vcpu" {
    description = "Vcpus required for a seed generator batch job"
    type        = string
}

variable "job_memory" {
    description = "Memory required for a seed generator batch job"
    type        = string
}

variable "binaries_oss_bucket" {
  type        = string
  description = "The OSS bucket where binaries is stored."
}

variable "batch_job_timeout" {
  type        = string
  description = "Number of seconds a uhs seeder batch job can run before timing out"
  default = 1209600
}

variable "tags" {
  type        = map(string)
  description = "Tags to set for all resources"
  default     = {}
}
