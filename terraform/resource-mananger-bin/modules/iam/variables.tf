variable tenancy_ocid {}

variable compartment_id {
  type        = string
  description = "ocid of the compartment to provision the resources in"
}

variable region_name {
  type        = string
  description = "region name for setting up os replication policy"
}