
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-240311031710580315"
  location = "West Europe"
}
resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks240311031710580315"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks240311031710580315"
  default_node_pool {
    name                    = "default"
    node_count              = 1
    vm_size                 = "Standard_D2s_v3"
    custom_ca_trust_enabled = "true"
  }
  identity {
    type = "SystemAssigned"
  }
}
