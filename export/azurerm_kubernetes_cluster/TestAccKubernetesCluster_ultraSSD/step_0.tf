
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-230721014802867154"
  location = "West Europe"
}
resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks230721014802867154"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks230721014802867154"

  default_node_pool {
    name                        = "default"
    temporary_name_for_rotation = "temp"
    node_count                  = 1
    vm_size                     = "Standard_D2s_v3"
    ultra_ssd_enabled           = false
    zones                       = ["1", "2", "3"]
  }

  identity {
    type = "SystemAssigned"
  }
}
