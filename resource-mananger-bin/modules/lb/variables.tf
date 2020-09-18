variable display_name {
  type        = string
  description = "name of load balancer"
  default     = "lb-public"
}

variable backendset_display_name {
  type        = string
  description = "name of load balancer"
  default     = "lb-bes1"
}

variable is_private {
  type        = string
  description = "is the load balancer private or public"
}

variable shape {
  type        = string
  description = "A template that determines the total pre-provisioned bandwidth (ingress plus egress). "
}

variable freeform_tags {
  type        = map
  description = "map of freeform tags to apply to all resources created by this module"
  default     = {}
}

variable defined_tags {
  type        = map
  description = "map of defined tags to apply to all resources created by this module"
  default     = {}
}

variable listener_port {
  type        = string
  description = "The communication port for the listener"
  default     = "80"
}

variable backend_port {
  type        = string
  description = "The backend server port against which to run the health check."
  default     = "80"
}

variable health_timeout {
  type        = string
  description = "The maximum time, in milliseconds, to wait for a reply to a health check."
  default     = "15"
}

variable health_protocol {
  type        = string
  description = "The protocol the health check must use; either HTTP or TCP."
  default     = "HTTP"
}

variable persistence_cookie_name {
  type        = string
  description = "The name of the cookie inserted by the load balancer."
  default     = "lb-session1"
}

variable subnet_id {
  type        = string
  description = "load balancer subnet id"
}

variable compartment_id {
  type        = string
  description = "ocid of the compartment to provision the resources in"
}

variable instance_private_ip {
  type        = string
  description = "private ip of app instance 1"
}
/*
variable instance2_private_ip {
  type        = string
  description = "private ip of app instance 2"
}
*/
variable add_backend_set {
  description = "If true, add servers to the backendset of load balancer"
  type        = bool 
}