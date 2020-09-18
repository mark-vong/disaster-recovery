output "dynamicGroups" {
  value = "${data.oci_identity_dynamic_groups.dr-dynamic-groups.dynamic_groups}"
}

output "dynamicPolicies" {
  value = "${data.oci_identity_policies.dr-dynamic-policies-1.policies}"
}