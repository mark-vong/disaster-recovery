output "dr_lb_ip" {
  value = "${oci_load_balancer_load_balancer.lb1.ip_address_details[0].ip_address}"
}