// Copyright (c) 2019, Oracle and/or its affiliates. All rights reserved.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

# OCI Provider variables
variable "tenancy_ocid" {}
variable "region" {}

# Deployment variables
variable "compartment_ocid" {
  type        = string
  description = "ocid of the compartment to deploy the bastion host in"
}

variable "dr_region" {
  type        = string
  description = "dr region name for disaster recovery"
}

variable "freeform_tags" {
  type        = map
  description = "map of freeform tags to apply to all resources"
  default     = {
    "Environment" =  "dr"
  }
}

variable "defined_tags" {
  type        = map
  description = "map of defined tags to apply to all resources"
  default     = {}
}

variable "dr_vcn_cidr_block" {
  type        = string
  description = "dr vcn cidr block"
  default     = "10.0.0.0/16"
}

variable "vcn_cidr_block" {
  type        = string
  description = "dr vcn cidr block"
  default     = "192.168.0.0/16"
}

variable "vcn_dns_label" {
    description = "DNS label for Virtual Cloud Network (VCN)"
    default = "drvcn"
}

variable "lb_display_name" {
	description = "Display label for Load Balancer"
	default = "dr_public_lb"
}

variable "is_private_lb" {
	description = "Display label for Load Balancer"
	default = "false"
}

variable "ssh_public_key_file" {
  type        = string
  description = "path to public ssh key for all instances deployed in the environment"
}

variable "ssh_private_key_file" {
  type        = string
  description = "path to private ssh key to acccess all instance in the deployed environment"
} 

variable bastion_server_shape {
  type        = string
  description = "oci shape for the instance"
  default     = "VM.Standard2.1"
}

variable "appserver_1_display_name" {
  type        = string
  description = "display name of app server1"
  default     = "app1"
}

variable "appserver_2_display_name" {
  type        = string
  description = "display name of app server2"
  default     = "app2"
} 

variable app_server_shape {
  type        = string
  description = "oci shape for the instance"
  default     = "VM.Standard2.2"
}

variable "db_display_name" {
  type        = string
  description = "display name of app server2"
  default     = "ActiveDBSystem"
}

variable "db_system_shape" {
  type        = string
  description = "shape of database instance"
  default     = "VM.Standard2.2"
}

variable "db_admin_password" {
  type        = string
  description = "password for SYS, SYSTEM, PDB Admin and TDE Wallet."
}

variable lb_shape {
  type        = string
  description = "A template that determines the total pre-provisioned bandwidth (ingress plus egress). Choose appropriate value based on the shapes available for the tenancy"
  default     = "400Mbps"
}

variable "export_read_only_access_source" {
  type        = string
  description = "Clients these options should apply to. Must be a either single IPv4 address or single IPv4 CIDR block."
  default = "0.0.0.0/0"
}

variable src_user_data {
  type        = string
  description = "userdata content"
  default     = "data.template_file.bootstrap_src.rendered"
}

variable dst_user_data {
  type        = string
  description = "userdata content"
  default     = "data.template_file.bootstrap_dst.rendered"
}


