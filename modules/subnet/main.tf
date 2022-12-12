resource "google_compute_subnetwork" "subnet" {
  name          = "${var.prefix}-${var.region}-subnet"
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  network       = var.vpc_name

  secondary_ip_range {
    range_name    = "${var.region}-cluster-secondary-range"
    ip_cidr_range = var.subnet_secondary_range_1_cidr
  }

  secondary_ip_range {
    range_name    = "${var.region}-services-secondary-range"
    ip_cidr_range = var.subnet_secondary_range_2_cidr
  }
}
