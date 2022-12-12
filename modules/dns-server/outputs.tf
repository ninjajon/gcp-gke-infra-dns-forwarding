output "ip" {
    value = google_compute_instance.server.network_interface.0.network_ip
}