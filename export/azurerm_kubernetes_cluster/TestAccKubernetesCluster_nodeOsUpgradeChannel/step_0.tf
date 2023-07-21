
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-230721011402452223"
  location = "West Europe"
}
resource "azurerm_kubernetes_cluster" "test" {
  name                    = "acctestaks230721011402452223"
  location                = azurerm_resource_group.test.location
  resource_group_name     = azurerm_resource_group.test.name
  dns_prefix              = "acctestaks230721011402452223"
  node_os_channel_upgrade = "Unmanaged"
  default_node_pool {
    name       = "default"
    vm_size    = "Standard_DS2_v2"
    node_count = 1
  }
  identity {
    type = "SystemAssigned"
  }
}
