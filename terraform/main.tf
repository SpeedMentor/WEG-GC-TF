# 1. VPC Network
#resource "google_compute_network" "main_vpc" {
#  name                    = "case-vpc"
#  auto_create_subnetworks = false
#}

# 2. Subnet
#resource "google_compute_subnetwork" "main_subnet" {
#  name          = "case-subnet"
#  ip_cidr_range = "10.10.0.0/16"
#  region        = "europe-west1"
#  network       = google_compute_network.main_vpc.id
#}

# 3. GKE Cluster
resource "google_container_cluster" "primary" {
  name     = "case-cluster"
  location = "europe-west1"
  node_locations = ["europe-west1-b"]
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = "default"
  subnetwork = "default"

  logging_service    = "none"
  monitoring_service = "none"

  # Enable Kubernetes API access from public internet for simplicity
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "0.0.0.0/0"
      display_name = "All networks"
    }
  }
}

# 4. main-pool (autoscaling kapalı)
resource "google_container_node_pool" "main_pool" {
  name       = "main-pool"
  cluster    = google_container_cluster.primary.name
  location   = google_container_cluster.primary.location

  node_count = 1
  node_config {
    machine_type = "n2d-standard-2"
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    labels = {
      pool = "main"
    }
  }
}

# 5. application-pool (autoscaling açık)
resource "google_container_node_pool" "application_pool" {
  name       = "application-pool"
  cluster    = google_container_cluster.primary.name
  location   = google_container_cluster.primary.location

  initial_node_count = 1
  node_config {
    machine_type = "n2d-standard-2"
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    labels = {
      pool = "application"
    }
  }

  autoscaling {
    min_node_count  = 1
    max_node_count  = 3
  }
}
