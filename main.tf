# VPC in the cloud
module "vpc" {
  source = "./modules/vpc"
  providers = {
    google = google.target
  }
  prefix = var.prefix
}

# Subnet App
module "subnet_app" {
  source = "./modules/subnet"
  providers = {
    google = google.target
  }
  prefix                        = "${var.prefix}-app"
  region                        = var.region
  subnet_cidr                   = "10.10.0.0/24"
  vpc_name                      = module.vpc.vpc_name
  subnet_secondary_range_1_cidr = "192.168.0.0/24"
  subnet_secondary_range_2_cidr = "192.168.1.0/24"
}

# Subnet Client
module "subnet_client" {
  source = "./modules/subnet"
  providers = {
    google = google.target
  }
  prefix                        = "${var.prefix}-client"
  region                        = var.region
  subnet_cidr                   = "10.20.0.0/24"
  vpc_name                      = module.vpc.vpc_name
  subnet_secondary_range_1_cidr = "10.20.1.0/24"
  subnet_secondary_range_2_cidr = "10.20.2.0/24"
}

module "firewall" {
  source = "./modules/firewall"
  providers = {
    google = google.target
  }
  prefix              = var.prefix
  vpc_name            = module.vpc.vpc_name  
}

module "nat" {
  source = "./modules/nat"
  providers = {
    google = google.target
  }
  prefix   = var.prefix
  vpc_name = module.vpc.vpc_name
  region   = var.region
}

module "dns-server" {
  source = "./modules/dns-server"
  providers = {
    google = google.target
  }
  prefix      = var.prefix
  subnet_name = module.subnet_client.subnet_name
  region      = var.region
}

module "workload_identity" {
  source = "./modules/workload-identity"
  providers = {
    google = google.target
  }
  prefix = var.prefix
  region = var.region
  roles = [
    "roles/storage.objectViewer",
    "roles/logging.viewer",
    "roles/logging.logWriter",
    "roles/cloudtrace.agent",
    "roles/artifactregistry.reader",
    "roles/monitoring.metricWriter"
  ]
}

module "gke" {
  source = "./modules/gke"
  providers = {
    google = google.target
  }
  prefix                        = var.prefix
  region                        = var.region
  subnet_name                   = module.subnet_app.subnet_name
  default_max_pods_per_node     = 20
  vpc_name                      = module.vpc.vpc_name
  gke_num_nodes                 = 1
  master_ipv4_cidr_block        = "10.10.1.0/28"
  cluster_service_account_email = module.workload_identity.cluster_service_account_email
}

module "dns" {
  source = "./modules/cloud-dns"
  providers = {
    google = google.target
  }
  prefix     = var.prefix
  server_ip  = module.dns-server.ip
  network_id = module.vpc.vpc_id
}

