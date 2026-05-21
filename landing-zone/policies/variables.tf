variable "org_management_group_name" {
  type    = string
  default = "PLACEHOLDER_ORG_NAME"
}

variable "allowed_locations" {
  type    = list(string)
  default = ["PLACEHOLDER_PRIMARY_REGION", "PLACEHOLDER_SECONDARY_REGION"]
}
