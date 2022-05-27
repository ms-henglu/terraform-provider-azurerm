
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220527024551939137"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt220527024551939137"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
