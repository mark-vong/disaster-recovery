// Copyright (c) 2019, Oracle and/or its affiliates. All rights reserved.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

/*
 * Creates a bastion host instance and copies the provided public and private ssh keys
 * to the instance to access to the remove instances through the bastion
 */

provider oci {
  alias = "destination"
}

resource "oci_identity_dynamic_group" "dr-dynamic-group" {
  provider = oci.destination

  compartment_id = "${var.tenancy_ocid}"
  name           = "dr-dynamic-group-SantaMonica-ORM"
  description    = "dynamic group created for dr to execute python scripts"
  matching_rule  = "ANY {instance.compartment.id = '${var.compartment_id}'}"
}

data "oci_identity_dynamic_groups" "dr-dynamic-groups" {
  provider = oci.destination
  compartment_id = "${var.tenancy_ocid}"

  filter {
    name   = "id"
    values = ["${oci_identity_dynamic_group.dr-dynamic-group.id}"]
  }
}

/*
 * Policies for dynamic groups
 */
resource "oci_identity_policy" "dr-dynamic-policy" {
  provider = oci.destination

  name           = "dr-dynamic-policy-2-SantaMonica-ORM"
  description    = "dynamic policy created for dr to execute python scripts"
  compartment_id = "${var.compartment_id}"

  statements = ["Allow dynamic-group ${oci_identity_dynamic_group.dr-dynamic-group.name} to manage all-resources in compartment ${data.oci_identity_compartment.dr_compartment.name}",
  ]
}

data "oci_identity_policies" "dr-dynamic-policies-1" {
  provider = oci.destination

  compartment_id = "${var.compartment_id}"

  filter {
    name   = "id"
    values = ["${oci_identity_policy.dr-dynamic-policy.id}"]
  }
}


data "oci_identity_compartment" "dr_compartment" {
  provider = oci.destination
  
  #Required
  id = "${var.compartment_id}"
}

/*
 * Policies for object storage replication
 */
resource "oci_identity_policy" "dr-os-replication-policy" {
  provider = oci.destination

  name           = "dr-os-replication-policy-SantaMonica-ORM"
  description    = "policy created for os replication management"
  compartment_id = "${var.tenancy_ocid}"

  statements = ["Allow service objectstorage-${var.region_name} to manage object-family in tenancy",]
}