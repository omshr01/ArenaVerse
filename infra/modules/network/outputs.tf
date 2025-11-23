output "network_self_link" {
  description = "Self-link of the VPC network"
  value       = google_compute_network.this.self_link
}

output "ca_subnet_self_link" {
  description = "Self-link of the CA main subnet"
  value       = google_compute_subnetwork.ca_main.self_link
}

output "eu_subnet_self_link" {
  description = "Self-link of the EU main subnet"
  value       = google_compute_subnetwork.eu_main.self_link
}

output "ca_subnet_name" {
  value = google_compute_subnetwork.ca_main.name
}

output "eu_subnet_name" {
  value = google_compute_subnetwork.eu_main.name
}
