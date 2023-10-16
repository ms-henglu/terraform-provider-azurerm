
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-231016033638249659"
  location = "West Europe"
}
resource "azurerm_kubernetes_cluster" "test" {
  name                              = "acctestaks231016033638249659"
  location                          = azurerm_resource_group.test.location
  resource_group_name               = azurerm_resource_group.test.name
  dns_prefix                        = "acctestaks231016033638249659"
  role_based_access_control_enabled = true
  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
  }
  identity {
    type = "SystemAssigned"
  }
  custom_ca_trust_certificates_base64 = []
}
