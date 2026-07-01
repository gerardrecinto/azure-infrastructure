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

variable "tenant_id" {
  type    = string
  default = "PLACEHOLDER_TENANT_ID"
}

variable "aks_admin_group_object_ids" {
  type        = list(string)
  description = "Azure AD group object IDs granted cluster-admin via Azure RBAC"
  default     = ["PLACEHOLDER_AKS_ADMIN_GROUP_OBJECT_ID"]
}

variable "kubernetes_version" {
  type    = string
  default = "1.29"
}

variable "pod_cidr" {
  type    = string
  default = "PLACEHOLDER_POD_CIDR"
}

variable "service_cidr" {
  type    = string
  default = "PLACEHOLDER_SVC_CIDR"
}

variable "dns_service_ip" {
  type    = string
  default = "PLACEHOLDER_DNS_SVC_IP"
}

variable "workload_vm_size" {
  type    = string
  default = "Standard_D8ds_v5"
}

variable "workload_node_count" {
  type    = number
  default = 3
}

variable "tags" {
  type = map(string)
  default = {
    managed-by  = "terraform"
    workload    = "aks-platform"
    environment = "PLACEHOLDER_ENV"
  }
}
