data "google_project" "project" {
}

resource "google_container_cluster" "cluster" {
  name     = "${var.prefix}-${var.region}-cluster"
  location = var.region

  remove_default_node_pool  = true
  initial_node_count        = 1
  network                   = var.vpc_name
  subnetwork                = var.subnet_name
  default_max_pods_per_node = var.default_max_pods_per_node

  workload_identity_config {
    workload_pool = "${data.google_project.project.project_id}.svc.id.goog"
  }

  node_config {
    shielded_instance_config {
      enable_secure_boot = true
    }
  }

  lifecycle {
    ignore_changes = [
      node_config
    ]
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = "${var.region}-cluster-secondary-range"
    services_secondary_range_name = "${var.region}-services-secondary-range"
  }
}

resource "google_container_node_pool" "node_pool" {
  name       = "${google_container_cluster.cluster.name}-pool"
  cluster    = google_container_cluster.cluster.name
  location   = var.region
  node_count = var.gke_num_nodes

  node_config {
    shielded_instance_config {
      enable_secure_boot = true
    }

    service_account = var.cluster_service_account_email

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/logging.read",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/devstorage.read_only"
    ]

    preemptible  = true
    machine_type = "n1-standard-1"
    image_type   = "UBUNTU_CONTAINERD"
    tags         = ["gke-node", "http-server"]
    metadata = {
      disable-legacy-endpoints = "true"
    }

    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }
}

# health check
resource "google_compute_health_check" "health_check" {
  name               = "${var.prefix}-${var.region}-hc"
  check_interval_sec = 1
  timeout_sec        = 1
  tcp_health_check {
    port = "80"
  }
}
