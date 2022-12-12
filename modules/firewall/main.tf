#### Firewall Rule for IAP ####
resource "google_compute_firewall" "iap_for_tcp_forwarding" {
  name          = "${var.vpc_name}-${var.prefix}-allow-iap"
  network       = var.vpc_name
  target_tags   = ["bastion", "dns-server", "gke-node"]
  source_ranges = ["35.235.240.0/20"]

  allow {
    protocol = "tcp"
    ports    = ["22", "3389"]
  }

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

#### Firewall Rule for dns ####
resource "google_compute_firewall" "allow_dns" {
  name          = "${var.vpc_name}-${var.prefix}-allow-dns"
  network       = var.vpc_name
  target_tags   = ["dns-server"]
  source_ranges = ["35.199.192.0/19"]

  allow {
    protocol = "tcp"
    ports    = ["53"]
  }

  allow {
    protocol = "udp"
    ports    = ["53"]
  }

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}
