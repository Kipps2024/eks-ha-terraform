locals {
  create_ingress = var.ingress_host != "" && var.acm_certificate_arn != ""
}

resource "kubernetes_ingress_v1" "app_public_alb" {
  count = local.create_ingress ? 1 : 0

  metadata {
    name      = "app-public-alb"
    namespace = "default"
    annotations = {
      "kubernetes.io/ingress.class"               = "alb"
      "alb.ingress.kubernetes.io/scheme"          = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"     = "ip"
      "alb.ingress.kubernetes.io/listen-ports"    = "[{\"HTTP\":80},{\"HTTPS\":443}]"
      "alb.ingress.kubernetes.io/ssl-redirect"    = "443"
      "alb.ingress.kubernetes.io/certificate-arn" = var.acm_certificate_arn

      # Health checks on /
      "alb.ingress.kubernetes.io/healthcheck-path"             = "/"
      "alb.ingress.kubernetes.io/healthcheck-port"             = "traffic-port"
      "alb.ingress.kubernetes.io/success-codes"                = "200-399"
      "alb.ingress.kubernetes.io/healthcheck-interval-seconds" = "15"
      "alb.ingress.kubernetes.io/healthcheck-timeout-seconds"  = "5"
      "alb.ingress.kubernetes.io/healthy-threshold-count"      = "2"
      "alb.ingress.kubernetes.io/unhealthy-threshold-count"    = "2"

      "alb.ingress.kubernetes.io/load-balancer-attributes" = "routing.http2.enabled=true,idle_timeout.timeout_seconds=60"
    }
  }

  spec {
    ingress_class_name = "alb"

    rule {
      host = var.ingress_host

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = var.app_service_name
              port {
                number = var.app_service_port
              }
            }
          }
        }
      }
    }
  }

  depends_on = [kubernetes_ingress_class_v1.alb]
}
