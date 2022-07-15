
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220715014630564380"
  location = "West Europe"
}

resource "azurerm_kusto_cluster" "test" {
  name                          = "acctestkcpnr9g"
  location                      = azurerm_resource_group.test.location
  resource_group_name           = azurerm_resource_group.test.name
  public_network_access_enabled = false
  public_ip_type                = "DualStack"
  sku {
    name     = "Standard_D13_v2"
    capacity = 2
  }
}
