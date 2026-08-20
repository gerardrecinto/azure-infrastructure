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

variable "aks_vnet_name" {
  type = string
}

variable "namespace_name" {
  type    = string
  default = "PLACEHOLDER_SB_NAMESPACE"
}

variable "capacity" {
  type        = number
  description = "Messaging units for the Premium Service Bus namespace."
  default     = 1

  validation {
    condition     = contains([1, 2, 4, 8, 16], var.capacity)
    error_message = "capacity must be one of 1, 2, 4, 8, or 16 messaging units (Service Bus Premium tier)."
  }
}

variable "topics" {
  type = map(object({
    max_size_mb         = number
    default_ttl         = string
    partitioned         = bool
    support_ordering    = bool
    duplicate_detection = bool
    subscriptions = map(object({
      max_delivery_count = number
      message_ttl        = string
    }))
  }))
  default = {}
}

variable "queues" {
  type = map(object({
    max_size_mb         = number
    default_ttl         = string
    max_delivery_count  = number
    partitioned         = bool
    duplicate_detection = bool
  }))
  default = {}
}

variable "sender_principal_ids" {
  type    = list(string)
  default = []
}

variable "receiver_principal_ids" {
  type    = list(string)
  default = []
}

variable "tags" {
  type = map(string)
  default = {
    managed-by  = "terraform"
    workload    = "messaging"
    environment = "PLACEHOLDER_ENV"
  }
}
