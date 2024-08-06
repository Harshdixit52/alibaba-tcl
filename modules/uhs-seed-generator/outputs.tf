output "job_name" {
  value       = local.name
  description = "Name of uhs seed generator job"
}

output "job_definition_id" {
  value       = alicloud_batch_job_definition.this.id
  description = "ID of the uhs_seed_generator job definition"
}

output "job_queue_id" {
  value       = alicloud_batch_job_queue.this.id
  description = "ID of the uhs_seed_generator job queue"
}

output "cr_repo_url" {
  value       = alicloud_cr_repo.this.repo_namespace
  description = "The CR repo for the uhs seed generator"
}
