locals {
  script = <<EOF
  # Install IIS
  Install-WindowsFeature -name DNS;
  Install-windowsfeature -name RSAT-DNS-Server;
  Add-DnsServerPrimaryZone -Name "jo.com" -ZoneFile "jo.com.dns"
  Add-DnsServerResourceRecordA -Name "test1" -ZoneName "jo.com" -AllowUpdateAny -IPv4Address "1.2.3.4" -TimeToLive 00:00:10
  New-Item -Path "c:\" -Name "startup_script.txt" -ItemType "file" -Value "The startup script ran"
  EOF
}

resource "google_compute_instance" "server" {
  zone         = "${var.region}-a"
  name         = "${var.prefix}-dns-server"
  machine_type = "n2-standard-2"
  tags         = ["dns-server"]
  metadata = {
    sysprep-specialize-script-ps1 = local.script
  }

  boot_disk {
    initialize_params {
      image = "windows-cloud/windows-2019"
    }
  }

  network_interface {
    subnetwork = var.subnet_name
  }

  shielded_instance_config {
    enable_secure_boot = true
  }
}
