
resource "kubernetes_deployment" "metrics_server" {
  metadata {
    name      = "metrics-server"
    namespace = var.namespace

    labels = {
      k8s-app = "metrics-server"
    }
  }

  spec {
    selector {
      match_labels = {
        k8s-app = "metrics-server"
      }
    }

    template {
      metadata {
        labels = {
          k8s-app = "metrics-server"
        }
      }

      spec {
        volume {
          name = "tmp-dir"
           empty_dir {}
        }

        container {
          name  = "metrics-server"
          image = "k8s.gcr.io/metrics-server/metrics-server:v0.6.1"
          args  = ["--cert-dir=/tmp", "--secure-port=4443", "--kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname", "--kubelet-use-node-status-port", "--metric-resolution=15s"]

          port {
            name           = "https"
            container_port = 4443
            protocol       = "TCP"
          }

          resources {
            requests = {
              cpu = "100m"

              memory = "200Mi"
            }
          }

          volume_mount {
            name       = "tmp-dir"
            mount_path = "/tmp"
          }

          liveness_probe {
            http_get {
              path   = "/livez"
              port   = "https"
              scheme = "HTTPS"
            }

            period_seconds    = 10
            failure_threshold = 3
          }

          readiness_probe {
            http_get {
              path   = "/readyz"
              port   = "https"
              scheme = "HTTPS"
            }

            initial_delay_seconds = 20
            period_seconds        = 10
            failure_threshold     = 3
          }

          image_pull_policy = "IfNotPresent"

          security_context {
            run_as_user               = 1000
            run_as_non_root           = true
            read_only_root_filesystem = true
          }
        }

        node_selector = {
          "kubernetes.io/os" = "linux"
        }

        service_account_name = "metrics-server"
        priority_class_name  = "system-cluster-critical"
      }
    }
  }
}
