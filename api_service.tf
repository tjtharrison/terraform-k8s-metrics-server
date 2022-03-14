resource "kubernetes_api_service" "v1_beta" {
  metadata {
    name = "v1beta1.metrics.k8s.io"

    labels = {
      k8s-app = "metrics-server"
    }
  }

  spec {
    service {
      namespace = var.namespace
      name      = "metrics-server"
    }

    group                    = "metrics.k8s.io"
    version                  = "v1beta1"
    insecure_skip_tls_verify = true
    group_priority_minimum   = 100
    version_priority         = 100
  }
}
