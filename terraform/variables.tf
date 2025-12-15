variable "resource_group_name" {
  description = "Nom du resource group Azure"
  type        = string
  default     = "rg-chat-devops"
}

variable "location" {
  description = "Région Azure"
  type        = string
  default     = "westeurope"
}

variable "aks_cluster_name" {
  description = "Nom du cluster AKS"
  type        = string
  default     = "aks-chat-devops"
}

variable "node_count" {
  description = "Nombre de nodes dans le cluster"
  type        = number
  default     = 2
}

variable "vm_size" {
  description = "Taille des VMs"
  type        = string
  default     = "Standard_D2_v2"
}

variable "acr_name" {
  description = "Nom du Container Registry (doit être unique)"
  type        = string
  default     = "acrchatdevops"
}

variable "key_vault_name" {
  description = "Nom du Key Vault (doit être unique)"
  type        = string
  default     = "kv-chat-devops"
}

variable "environment" {
  description = "Environnement"
  type        = string
  default     = "production"
}
