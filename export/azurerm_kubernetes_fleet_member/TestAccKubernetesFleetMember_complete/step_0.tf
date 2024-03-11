

variable "primary_location" {
  default = "West Europe"
}
variable "random_integer" {
  default = 240311031710590052
}
variable "random_string" {
  default = "gd0m7"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks${var.random_string}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks${var.random_string}"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }
}


resource "azurerm_kubernetes_fleet_manager" "test" {
  name                = "acctestkfm${var.random_string}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_resource_group" "test" {
  name     = "acctestrg-${var.random_integer}"
  location = var.primary_location
}


provider "azurerm" {
  features {}
}

resource "azurerm_kubernetes_fleet_member" "test" {
  kubernetes_cluster_id = azurerm_kubernetes_cluster.test.id
  kubernetes_fleet_id   = azurerm_kubernetes_fleet_manager.test.id
  name                  = "acctestkfm-${var.random_string}"
  group                 = "val-${var.random_string}"
}
