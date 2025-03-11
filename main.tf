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

provider "google" {
  region = var.region
}

resource "random_id" "random_suffix" {
  byte_length = 4
}

locals {
  gcs_bucket_name = "tmp-dir-bucket-${random_id.random_suffix.hex}"
}

module "vpc" {
  source       = "terraform-google-modules/network/google"
  version      = "~> 10.0"
  project_id   = var.project_id
  network_name = "dataflow-network-part2"

  subnets = [
    {
      subnet_name   = "dataflow-subnetwork-part2"
      subnet_ip     = "10.1.3.0/24"
      subnet_region = "us-central1"
      subnet_private_access = "true"
    },
  ]

  secondary_ranges = {
    dataflow-subnetwork = [
      {
        range_name    = "my-secondary-range"
        ip_cidr_range = "192.168.64.0/24"
      },
    ]
  }
}



module "bucket" {
  source  = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version = "~> 9.0"

  name       = local.gcs_bucket_name
  project_id = var.project_id
  location   = var.region

  lifecycle_rules = [{
    action = {
      type = "Delete"
    }
    condition = {
      age            = 365
      with_state     = "ANY"
      matches_prefix = var.project_id
    }
  }]

  iam_members = [{
    role   = "roles/storage.objectViewer"
    member = "group:cloud-control2-appdesigncenter-dev-jobs@twosync.google.com"
  }]

  autoclass = true
}


module "dataflow-job" {
  source = "github.com/terraform-google-modules/terraform-google-dataflow//modules/flex"
  
  #version = "0.1.0"

  project_id            = var.project_id
  name                  = "pubsub-to-gcs-update-testing"
  on_delete             = "cancel"
  region                = var.region
  max_workers           = 1
  #template_gcs_path     = "gs://dataflow-templates/latest/Word_Count"
  
  container_spec_gcs_path    = "gs://template-pubsub-to-gcs/images/2025_03_10_01/flex/Cloud_PubSub_to_GCS_Text_Flex"
  #temp_gcs_location     = module.bucket.name
  temp_location     = "gs://${module.bucket.name}/tmp_dir"
  service_account_email = var.service_account_email
  network_name          = module.vpc.network_self_link
  subnetwork            = module.vpc.subnets_self_links[0]
  machine_type          = "n1-standard-1"

  parameters = {
    pub_sub_1_InputTopic = "projects/cloud-appcenter-e2e-testing/topics/gcs-update-testing"
    cloud_storage_1_OutputDirectory = "gs://pubsub-gcs-write-testing/data/"
    cloud_storage_1_OutputFilenamePrefix = "testing-"
  }
}

module "dataflow-job-2" {
  source = "github.com/terraform-google-modules/terraform-google-dataflow//modules/legacy"

  #source  = "terraform-google-modules/dataflow/google//modules/legacy"
  #version = "0.1.0"

  project_id            = var.project_id
  name                  = "wordcount-terraform-example-2"
  on_delete             = "cancel"
  region                = var.region
  max_workers           = 1
  template_gcs_path     = "gs://dataflow-templates/latest/Word_Count"
  #container_spec_gcs_path    = "gs://dataflow-templates/latest/Word_Count"
  temp_gcs_location     = module.bucket.name
  #temp_location     = module.bucket.name
  service_account_email = var.service_account_email
  network_name          = module.vpc.network_self_link
  subnetwork            = module.vpc.subnets_self_links[0]
  machine_type          = "n1-standard-2"

  parameters = {
    inputFile = "gs://dataflow-samples/shakespeare/kinglear.txt"
    output    = "gs://${local.gcs_bucket_name}/output/my_output"
  }

  labels = {
    example_name = "simple_example"
  }
}
