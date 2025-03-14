/**
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

output "project_id" {
  value       = var.project_id
  description = "The project's ID"
}

output "df_job_state" {
  description = "The state of the newly created Dataflow job"
  value       = module.dataflow-job.state
}

output "df_job_id" {
  description = "The unique Id of the newly created Dataflow job"
  value       = module.dataflow-job.id
}

output "df_job_name" {
  description = "The name of the newly created Dataflow job"
  value       = module.dataflow-job.name
}

output "df_job_state_2" {
  description = "The state of the newly created Dataflow job"
  value       = module.dataflow-job-2.state
}

output "df_job_id_2" {
  description = "The unique Id of the newly created Dataflow job"
  value       = module.dataflow-job-2.id
}

output "df_job_name_2" {
  description = "The name of the newly created Dataflow job"
  value       = module.dataflow-job-2.name
}

output "bucket_name" {
  description = "The name of the bucket"
  value       = module.bucket.name
}
