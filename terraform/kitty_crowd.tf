data "google_client_config" "kitty_crowd_config" {}

provider "kubernetes" {
  host "https://${google_container_cluster.kitty_crowd_cluster.deault.endpoint}"
  token = data.google_client_config.kitty_crowd_config.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.kitty_crowd_cluster.master_auth[0].cluster_ca_certificate)

  ignore_annotations = [
    "^autopilot\\.gke\\.io\\/.*",
    "^cloud\\.google\\.com\\/.*"
  ]
}

resource "kubernetes_deployment_v1" "kitty_crowd_deployment" {
  metadata {
    name = "kitty-crowd-deployment"
  }

  spec {
    selector {
      match_labels = {
        app = "kitty-crowd"
      }
    }

    template {
      metadata {
        labels = {
          app = "kitty-crowd"
        }
      }

      spec {
        container {
          image = kszymhu/kitty-crowd:main
          name = "kitty-crowd"

          port {
            container_port = 5000
            name = "kitty-crowd-svc"
          }

          security_context {
            allow_privilege_escalation = false
            privileged = false
            read_only_root_filesystem = false

            capabilities {
              add = []
              drop = ["NET_RAW"]
            }
          }

          liveness_probe {
            http_get {
              path = "/"
              port = "kitty-crowd-svc"

              http_header {
                name = "X-Custom-Header"
                value = "Awesome"
              }
            }

            initial_delay_seconds = 3
            period_seconds = 3
          }
        }

        security_context {
          run_as_non_root = true

          syscomp_profile {
            type = "RuntimeDefault"
          }
        }

        toleration {
          effect = "NoSchedule"
          key = "kubernetes.io/arch"
          operator = "Equal"
          value = "amd64"
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "kitty_crowd_loadbalancer" {
  metadata {
    name = "kitty-crowd-loadbalancer"
  }

  spec {
    selector = {
      app = kubernetes_deployment_v1.kitty_crowd_deployment.spec[0].selector[0].match_labels.app
    }

    ip_family_policy = "RequireDualStack"

    port = {
      port = 80
      target_port = kubernetes_deployment_v1.kitty_crowd_deployment.default.spec[0].template[0].spec[0].container[0].port[0].name
    }

    type = "LoadBalancer"
  }

  depends-on = [time_sleep.wait_service_cleanup]
}

resource "time_sleep" "wait_service_cleanup" {
  depends_on = [google_container_cluster.kitty_crowd_cluster]

  destroy_duration = "180s"
}

