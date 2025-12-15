terraform {
  required_version = ">= 1.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "chat_rg" {
  name     = var.resource_group_name
  location = var.location
  
  tags = {
    Environment = var.environment
    Project     = "ChatDevOps"
  }
}

# AKS Cluster
resource "azurerm_kubernetes_cluster" "chat_aks" {
  name                = var.aks_cluster_name
  location            = azurerm_resource_group.chat_rg.location
  resource_group_name = azurerm_resource_group.chat_rg.name
  dns_prefix          = "chatdevops"

  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = var.vm_size
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = var.environment
  }
}

# Container Registry
resource "azurerm_container_registry" "chat_acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.chat_rg.name
  location            = azurerm_resource_group.chat_rg.location
  sku                 = "Standard"
  admin_enabled       = true

  tags = {
    Environment = var.environment
  }
}

# Key Vault for secrets
resource "azurerm_key_vault" "chat_kv" {
  name                = var.key_vault_name
  location            = azurerm_resource_group.chat_rg.location
  resource_group_name = azurerm_resource_group.chat_rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  tags = {
    Environment = var.environment
  }
}

data "azurerm_client_config" "current" {}
