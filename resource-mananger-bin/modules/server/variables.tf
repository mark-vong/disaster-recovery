variable display_name {
  type        = string
  description = "name of instance"
}

variable hostname_label {
  type        = string
  description = "hostname label"
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

variable ping_all_id {
  type        = string
  description = "security group id"
}

variable compartment_id {
  type        = string
  description = "ocid of the compartment to provision the resources in"
}

variable "tenancy_ocid" {
  type        = string
  description = "tenancy ocid"
}

variable source_id {
  type        = string
  description = "ocid of the image to provistion the management instance with"
}

variable subnet_id {
  type        = string
  description = "ocid of the subnet to provision the management instance in"
}

variable availability_domain {
  type        = string
  description = "the availability downmain to provision the management instance in"
}

# TODO rename to `bastion_host` for consistency
variable bastion_ip {
  type        = string
  description = "host name or ip address of the bastion host for provisioning"
}

variable shape {
  type        = string
  description = "oci shape for the instance"
  default     = "VM.Standard2.2"
}

variable ssh_private_key_file {
  type        = string
  description = "the private ssh key to provision on the bastion host for access to remote instances"
}

variable ssh_public_key_file {
  type        = string
  description = "the public ssh key to provision on the bastion host for access to remote instances"
}

variable Size {
  type        = string
  description = "The size of the volume in GBs."
  default     = "50"
}

variable user_data {
  type        = string
  description = "userdata content"
  default     = null
}
