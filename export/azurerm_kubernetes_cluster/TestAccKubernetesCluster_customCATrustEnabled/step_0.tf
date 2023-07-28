
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-230728025358864035"
  location = "West Europe"
}
resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks230728025358864035"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks230728025358864035"
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
