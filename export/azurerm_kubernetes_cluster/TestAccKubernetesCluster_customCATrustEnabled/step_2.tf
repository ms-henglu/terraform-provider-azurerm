
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-230113180906260967"
  location = "West Europe"
}
resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks230113180906260967"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks230113180906260967"
  default_node_pool {
    name                    = "default"
    node_count              = 1
    vm_size                 = "Standard_D2s_v3"
    custom_ca_trust_enabled = "false"
  }
  identity {
    type = "SystemAssigned"
  }
}
