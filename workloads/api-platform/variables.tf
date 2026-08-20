variable "subscription_id" {
  type    = string
  default = "PLACEHOLDER_WORKLOADS_SUBSCRIPTION_ID"
}

variable "prefix" {
  type    = string
  default = "PLACEHOLDER_PREFIX"
}

variable "location" {
  type    = string
  default = "PLACEHOLDER_AZURE_REGION"
}

variable "api_vnet_name" {
  type = string
}

variable "keyvault_name" {
  type    = string
  default = "PLACEHOLDER_KV_NAME"
}

variable "apim_name" {
  type    = string
  default = "PLACEHOLDER_APIM_NAME"
}

variable "publisher_name" {
  type = string
}

variable "publisher_email" {
  type = string
}

variable "apim_sku_tier" {
  type    = string
  default = "Developer"
}

variable "apim_sku_capacity" {
  type    = number
  default = 1
}

variable "apim_hostname" {
  type = string
}

variable "jwt_tenant_id" {
  type    = string
  default = "PLACEHOLDER_TENANT_ID"
}

variable "jwt_audience" {
  type = string
}

variable "waf_mode" {
  type        = string
  description = "Front Door WAF policy mode."
  default     = "Prevention"

  validation {
    condition     = contains(["Detection", "Prevention"], var.waf_mode)
    error_message = "waf_mode must be either \"Detection\" or \"Prevention\"."
  }
}

variable "tags" {
  type = map(string)
  default = {
    managed-by  = "terraform"
    workload    = "api-platform"
    environment = "PLACEHOLDER_ENV"
  }
}
