output instance_ip {
  description = "the private ip of the instance"
  value       = oci_core_instance.private_server.private_ip
}