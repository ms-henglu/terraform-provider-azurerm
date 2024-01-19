
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-240119024742854101"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone240119024742854101.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks240119024742854101"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks240119024742854101"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  web_app_routing {
    dns_zone_id = ""
  }
}
 