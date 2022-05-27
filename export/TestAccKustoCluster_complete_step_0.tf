
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220527034311016858"
  location = "West Europe"
}

resource "azurerm_kusto_cluster" "test" {
  name                          = "acctestkc8gd47"
  location                      = azurerm_resource_group.test.location
  resource_group_name           = azurerm_resource_group.test.name
  public_network_access_enabled = false
  sku {
    name     = "Dev(No SLA)_Standard_D11_v2"
    capacity = 1
  }
}
