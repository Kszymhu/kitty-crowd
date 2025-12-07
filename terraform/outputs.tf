output "cluster_name" {
    value = google_container_cluster.kitty_cluster.name
}

output "cluster_endpoint" {
    value = google_container_cluster.kitty_cluster.endpoint
}