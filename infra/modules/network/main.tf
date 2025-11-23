resource "google_compute_network" "this" {
  name                    = var.network_name
  project                 = var.project_id
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

# ---------- Subnets ----------

resource "google_compute_subnetwork" "ca_main" {
  name          = "${var.network_name}-${var.ca_region}-main"
  project       = var.project_id
  region        = var.ca_region
  ip_cidr_range = var.ca_cidr
  network       = google_compute_network.this.id

  private_ip_google_access = true
}

resource "google_compute_subnetwork" "eu_main" {
  name          = "${var.network_name}-${var.eu_region}-main"
  project       = var.project_id
  region        = var.eu_region
  ip_cidr_range = var.eu_cidr
  network       = google_compute_network.this.id

  private_ip_google_access = true
}

# ---------- Firewall Rules ----------

# Allow SSH from your IP (optional)
resource "google_compute_firewall" "allow_ssh" {
  count   = var.ssh_source_cidr == null ? 0 : 1
  name    = "${var.network_name}-allow-ssh"
  project = var.project_id
  network = google_compute_network.this.name

  direction = "INGRESS"
  priority  = 1000

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = [var.ssh_source_cidr]

  description = "Allow SSH from trusted CIDR to bastion/VMs"
}

# Allow Google LB / health checks to reach backends
resource "google_compute_firewall" "allow_lb_healthchecks" {
  name    = "${var.network_name}-allow-lb-healthchecks"
  project = var.project_id
  network = google_compute_network.this.name

  direction = "INGRESS"
  priority  = 1000

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  # Standard Google LB & health check IP ranges
  source_ranges = [
    "130.211.0.0/22",
    "35.191.0.0/16",
  ]

  description = "Allow GCP load balancer & health checks"
}

# ---------- Cloud Routers & NAT ----------

resource "google_compute_router" "ca_router" {
  name    = "${var.network_name}-${var.ca_region}-router"
  project = var.project_id
  region  = var.ca_region
  network = google_compute_network.this.name
}

resource "google_compute_router" "eu_router" {
  name    = "${var.network_name}-${var.eu_region}-router"
  project = var.project_id
  region  = var.eu_region
  network = google_compute_network.this.name
}

resource "google_compute_router_nat" "ca_nat" {
  name    = "${var.network_name}-${var.ca_region}-nat"
  project = var.project_id
  router  = google_compute_router.ca_router.name
  region  = var.ca_region

  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.ca_main.name
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  enable_endpoint_independent_mapping = true
}

resource "google_compute_router_nat" "eu_nat" {
  name    = "${var.network_name}-${var.eu_region}-nat"
  project = var.project_id
  router  = google_compute_router.eu_router.name
  region  = var.eu_region

  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.eu_main.name
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  enable_endpoint_independent_mapping = true
}
