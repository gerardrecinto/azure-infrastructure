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
  type        = number
  description = "Retention period for the Log Analytics workspace (PerGB2018 SKU: 30-730 days)."
  default     = 90

  validation {
    condition     = var.log_retention_days >= 30 && var.log_retention_days <= 730
    error_message = "log_retention_days must be between 30 and 730 (valid range for the PerGB2018 SKU)."
  }
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
