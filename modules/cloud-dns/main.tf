resource "google_dns_policy" "dns_policy" {
  name                      = "fwd-to-windows-dns"
  enable_inbound_forwarding = true
  enable_logging            = true

  alternative_name_server_config {
    target_name_servers {
      ipv4_address    = var.server_ip
      forwarding_path = "private"
    }
  }

  networks {
    network_url = var.network_id
  }
}
