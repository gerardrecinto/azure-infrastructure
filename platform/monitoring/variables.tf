variable "subscription_id" {
  type    = string
  default = "PLACEHOLDER_MANAGEMENT_SUBSCRIPTION_ID"
}

variable "prefix" {
  type    = string
  default = "PLACEHOLDER_PREFIX"
}

variable "location" {
  type    = string
  default = "PLACEHOLDER_AZURE_REGION"
}

variable "log_retention_days" {
  type    = number
  default = 90
}

variable "alert_email_receivers" {
  type = list(object({
    name    = string
    address = string
  }))
  default = []
}

variable "tags" {
  type = map(string)
  default = {
    managed-by  = "terraform"
    workload    = "management"
    environment = "PLACEHOLDER_ENV"
  }
}
