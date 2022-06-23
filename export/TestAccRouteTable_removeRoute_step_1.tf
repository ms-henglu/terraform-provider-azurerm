
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220623223730196768"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt220623223730196768"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
