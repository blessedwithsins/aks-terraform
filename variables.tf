variable "resource_group_name" {
  description = "The resource group name to be imported"
  default = "terraform"
}

variable "location" {
    description = "The resource group will be in this location"
    default = "westeurope"
}

variable "cluster_name" {
    description = "The resource group will be in this location"
    default = "aks-terraform"
}

variable "aks_eip_name" {
    description = "AKS Egress Public IP"
    default     = "aks-terraform"
}

variable "prefix" {
  description = "The prefix for the resources created in the specified Azure Resource Group"
  default = "aks-terraform"
}

variable "dns_prefix" {
  description = "The prefix for the resources created in the specified Azure Resource Group"
  default = "aks-terraform"
}

variable "client_id" {
  description = "The Client ID (appId) for the Service Principal used for the AKS deployment"
  default = ""
}

variable "client_secret" {
  description = "The Client Secret (password) for the Service Principal used for the AKS deployment"
  default = ""
}

variable "admin_username" {
  default     = "azureuser"
  description = "The username of the local administrator to be created on the Kubernetes cluster"
}

variable "agent_size" {
  default     = "Standard_D4_v3"
  description = "The default virtual machine size for the Kubernetes agents"
}

variable "log_analytics_workspace_sku" {
  description = "The SKU (pricing level) of the Log Analytics workspace. For new subscriptions the SKU should be set to PerGB2018"
  default     = "PerGB2018"
}

variable "log_retention_in_days" {
  description = "The retention period for the logs in days"
  default     = 30
}

variable "agent_count" {
  description = "The number of Agents that should exist in the Agent Pool"
  default     = 2
}

variable "ssh_public_key" {
  description = "A custom ssh key to control access to the AKS cluster"
  default = "~/.ssh/id_rsa.pub"
  }

variable "tags" {
  type        = map(string)
  description = "Any tags that should be present on the Virtual Network resources"
  default     = {}
  
}

variable "enable_log_analytics_workspace" {
  type        = bool
  description = "Enable the creation of azurerm_log_analytics_workspace and azurerm_log_analytics_solution or not"
  default     = true
}