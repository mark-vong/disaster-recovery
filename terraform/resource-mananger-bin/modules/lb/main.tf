

provider oci {
  alias = "destination"
}

/* Load Balancer */

resource "oci_load_balancer_load_balancer" "lb1" {
  provider       = oci.destination
  shape          = var.shape
  compartment_id = var.compartment_id

  subnet_ids = [
    var.subnet_id,
  ]

  display_name               = var.display_name
  is_private                 = var.is_private
}

resource "oci_load_balancer_backend_set" "lb-bes1" {
  provider            = oci.destination
  name             = var.backendset_display_name
  load_balancer_id = oci_load_balancer_load_balancer.lb1.id
  policy           = "ROUND_ROBIN"

  health_checker {
    port                = var.backend_port
    protocol            = var.health_protocol
    response_body_regex = ".*"
    url_path            = "/"
  }

  session_persistence_configuration {
    cookie_name      = var.persistence_cookie_name
    disable_fallback = true
  }
}

resource "oci_load_balancer_listener" "lb-listener1" {
  provider            = oci.destination
  load_balancer_id         = oci_load_balancer_load_balancer.lb1.id
  name                     = "http"
  default_backend_set_name = oci_load_balancer_backend_set.lb-bes1.name
  port                     = var.listener_port
  protocol                 = var.health_protocol

  connection_configuration {
    idle_timeout_in_seconds = var.health_timeout
  }
}

resource "oci_load_balancer_backend" "lb-be1" {
  count            = var.add_backend_set ? 1 : 0
  provider         = oci.destination
  load_balancer_id = oci_load_balancer_load_balancer.lb1.id
  backendset_name  = oci_load_balancer_backend_set.lb-bes1.name
  ip_address       = var.instance_private_ip
  port             = var.backend_port
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}
/*
resource "oci_load_balancer_backend" "lb-be2" {
  count            = var.add_backend_set ? 1 : 0
  provider         = oci.destination
  load_balancer_id = oci_load_balancer_load_balancer.lb1.id
  backendset_name  = oci_load_balancer_backend_set.lb-bes1.name
  ip_address       = var.instance_private_ip
  port             = 80
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}
*/