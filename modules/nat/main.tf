resource "google_compute_router" "router" {
  name    = "${var.prefix}-nat-router"
  region  = var.region
  network = var.vpc_name
}

resource "google_compute_router_nat" "nat" {
  name                               = "${var.prefix}-${var.region}-nat"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
