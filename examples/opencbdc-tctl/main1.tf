module "opencbdc_tctl" {
  source = "../../"
  
  base_domain                                       = var.base_domain
  environment                                       = var.environment
  public_key                                        = var.ssh_public_key
  test_controller_launch_type                       = "ECS"  # Alibaba Cloud's ECS service
  test_controller_cpu                               = "10240"
  test_controller_memory                            = "65536"
  test_controller_health_check_grace_period_seconds = 600
  test_controller_github_access_token               = var.github_access_token
  lets_encrypt_email                                = var.lets_encrypt_email
}
