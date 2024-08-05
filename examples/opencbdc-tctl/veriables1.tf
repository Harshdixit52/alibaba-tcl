variable "environment" {
  type        = string
  description = "Alibaba Cloud tag to indicate environment name of each infrastructure object."
  default     = ""
}

variable "base_domain" {
  type = string
  description = "Base domain to use for Alibaba Cloud DNS management."
  default = ""
}

variable "ssh_public_key" {
  type = string
  description = "SSH public key to use in ECS instances."
  default = ""
}

variable "github_access_token" {
  description = "Access token for cloning test controller repo"
  type        = string
  default     = ""
}

variable "lets_encrypt_email" {
  description = "Email to associate with Let's Encrypt certificate"
  type = string
  default = ""
}
