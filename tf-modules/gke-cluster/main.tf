/**
 * Copyright 2021 Google LLC
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

resource "google_container_cluster" "primary" {
  project = var.project_id
  name     = var.gke_cluster_name
  location = var.region
  network = var.network
  subnetwork = var.subnetwork
  remove_default_node_pool = true
  initial_node_count       = 1
  ip_allocation_policy {}
  resource_labels = {
      "mesh_id" = "proj-${var.project_number}"
    }
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
}

resource "google_container_node_pool" "apigee-data" {
  project    = var.project_id
  name       = "apigee-data"
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = 1
  node_config {
    machine_type = "e2-standard-8"
    image_type = "COS"
    disk_type = "pd-ssd"
    disk_size_gb = 250
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    tags = ["apigee-data","gke-${var.gke_cluster_name}"]
  }
  management {
    auto_repair = true
    auto_upgrade = true
  }
  upgrade_settings {
    max_surge = 1
    max_unavailable = 0
  }
}

resource "google_container_node_pool" "apigee-runtime" {
  project    = var.project_id
  name       = "apigee-runtime"
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = 2
  node_config {
    machine_type = "e2-standard-8"
    image_type = "COS"
    disk_type = "pd-ssd"
    disk_size_gb = 10
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    tags = ["apigee-runtime","gke-${var.gke_cluster_name}"]
  }
  autoscaling {
    min_node_count = 2
    max_node_count = 4
  }
  management {
    auto_repair = true
    auto_upgrade = true
  }
  upgrade_settings {
    max_surge = 1
    max_unavailable = 0
  }
}