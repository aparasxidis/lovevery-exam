# ============================================================================================================
# # Namespace
# ============================================================================================================
resource "kubernetes_namespace" "_" {
  metadata {
    name = var.ns
  }
}

# ============================================================================================================
# # Deployment
# ============================================================================================================
resource "kubernetes_deployment" "_" {
    metadata {
        name = var.app_name
        namespace = kubernetes_namespace._.metadata.0.name
    }
    spec {
        replicas = 2
        selector {
            match_labels = {
                app = var.app_name
            }
        }
        template {
            metadata {
                labels = {
                    app = var.app_name
                }
            }
            spec {
                container {
                    image = "${var.registry}:${var.image_tag}"
                    name = var.app_name
                    port {
                        container_port = var.container_port
                    }
                }
            }
        }
    }
}

# ============================================================================================================
# # Service
# ============================================================================================================
resource "kubernetes_service" "_" {
    metadata {
        name = var.app_name
        namespace = kubernetes_namespace._.metadata.0.name
    }
    spec {
        selector = {
            app = kubernetes_deployment._.spec.0.template.0.metadata.0.labels.app
        }
        port {
            port = var.svc_port
        }
    }
}