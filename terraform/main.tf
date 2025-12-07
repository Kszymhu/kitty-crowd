provider "google" {
    project = var.project_id
    region = var.region
}

resource "google_container_cluster" "kitty_cluster" {
    name = "kitty-cluster"
    location = var.region
    initial_node_count = 1

    node_config {
        machine_type = "e2-medium"
        oauth_scopes = [
            "https://www.googleapis.com/auth/cloud-platform"
        ]
    }
}