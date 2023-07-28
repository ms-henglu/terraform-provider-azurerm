
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-230728032026624103"
  location = "West Europe"
}
resource "azurerm_kubernetes_cluster" "test" {
  name                    = "acctestaks230728032026624103"
  location                = azurerm_resource_group.test.location
  resource_group_name     = azurerm_resource_group.test.name
  dns_prefix              = "acctestaks230728032026624103"
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
