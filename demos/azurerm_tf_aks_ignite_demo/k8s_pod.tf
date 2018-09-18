provider "kubernetes" {
  host = "${azurerm_kubernetes_cluster.k8s.kube_config.0.host}"

  #username               = "${azurerm_kubernetes_cluster.k8s.kube_config.0.username}"
  #password               = "${azurerm_kubernetes_cluster.k8s.kube_config.0.password}"
  client_certificate = "${base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_certificate)}"

  client_key             = "${base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_key)}"
  cluster_ca_certificate = "${base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.cluster_ca_certificate)}"
}

resource "kubernetes_pod" "ignite-pod" {
  metadata {
    name = "ignite-k8s-nginx-pod"
  }

  spec {
    container {
      image = "nginx:1.7.9"
      name  = "example"
    }
  }

  tags {
    Environment = "${var.environment_tag}"
    build       = "${var.build_tag}"
  }
}

resource "kubernetes_service" "ignite-web" {
  metadata {
    name = "ignite-k8s-nginx-service"
  }

  spec {
    selector {
      name = "${kubernetes_pod.ignite-pod.metadata.0.name}"
    }

    session_affinity = "ClientIP"

    port {
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }

  tags {
    Environment = "${var.environment_tag}"
    build       = "${var.build_tag}"
  }
}
