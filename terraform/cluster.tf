resource "google_compute_network" "kitty_crowd_network" {
  name = "kitty-crowd-network"

  auto_create_subnetworks = false
  enable_ula_internal_ipv6 = true
}

resource "google_compute_subnetwork" "kitty_crowd_subnetwork" {
  name = "kitty-crowd-subnetwork"

  ip_cidr_range = "10.0.0.0/16"
  region = "europe-central2"

  stack_type = "IPV4_IPV6"
  ipv6_access_type = "EXTERNAL"

  network = google_compute_network.kitty_crowd_network.id
  secondary_ip_range {
    range_name = "services-range"
    ip_cidr_name = "192.168.0.0/24"
  }
}

resource "google_container_cluster" "kitty_crowd_cluster" {
  name = "kitty-crowd-cluster"

  location = "europe-central2"
  enable_autopilot = true
  enable_l4_ilb_subsetting = true

  network = google_compute_network.kitty_crowd_network.id
  subnetwork = google_compute_subnetwork.kitty_crowd_subnetwork.id

  ip_allocation_policy {
    stack_type = "IPV4_IPV6"
    services_secondary_range_name = google_compute_subnetwork.kitty_crowd_subnetwork.secondary_ip_range[0].range_name
    cluster_secondary_range_name = google_compute_subnetwork.kitty_crowd_subnetwork.secondary_ip_range[1].range_name
  }

  deletion_protection = false
}
