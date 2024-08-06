vpc_id_use1 = "vpc-12345678"
vpc_id_use2 = "vpc-87654321"
vpc_id_usw2 = "vpc-11223344"

public_subnets_use1 = ["subnet-12345678", "subnet-23456789"]
public_subnets_use2 = ["subnet-34567890", "subnet-45678901"]
public_subnets_usw2 = ["subnet-56789012", "subnet-67890123"]

private_subnets_use1 = ["subnet-78901234", "subnet-89012345"]
private_subnets_use2 = ["subnet-90123456", "subnet-01234567"]
private_subnets_usw2 = ["subnet-12345678", "subnet-23456789"]

ec2_public_key = "ssh-rsa AAAAB3...example..."

agent_instance_types = ["t2.micro", "t2.small"]

base_domain = "example.com"

create_networking = true

environment = "production"

test_controller_launch_type = "EC2"

test_controller_cpu = "256"
test_controller_memory = "512"
test_controller_health_check_grace_period_seconds = 60

transaction_processor_repo_url = "https://github.com/example/repo"
transaction_processor_main_branch = "main"
transaction_processor_github_access_token = "your-github-access-token"

lambda_build_in_docker = true

uhs_seed_generator_max_vcpus = 4
uhs_seed_generator_job_vcpu = 2
uhs_seed_generator_job_memory = 4096
uhs_seed_generator_batch_job_timeout = 3600

test_controller_github_repo = "https://github.com/example/test-controller"
test_controller_github_repo_owner = "owner"
test_controller_github_repo_branch = "main"
test_controller_github_access_token = "your-github-access-token"

test_controller_node_container_build_image = "example/node-image:latest"
test_controller_golang_container_build_image = "example/golang-image:latest"
test_controller_app_container_base_image = "example/app-image:latest"

create_opensearch = false

opensearch_master_user_name = "admin"
opensearch_master_user_password = "adminpassword"
opensearch_route53_record_ttl = 300
opensearch_engine_version = "1.0"
opensearch_instance_type = "t3.medium"
opensearch_instance_count = 2
opensearch_ebs_volume_type = "gp2"
opensearch_ebs_volume_size = 100

fire_hose_buffering_interval = "300"
fire_hose_index_rotation_period = "1d"

s3_interface_endpoint_use1 = "s3.us-east-1.amazonaws.com"
s3_interface_endpoint_use2 = "s3.us-east-2.amazonaws.com"
s3_interface_endpoint_usw2 = "s3.us-west-2.amazonaws.com"

cert_arn = "arn:aws:acm:region:account-id:certificate/certificate-id"

create_certbot_lambda = true
lets_encrypt_email = "example@example.com"
