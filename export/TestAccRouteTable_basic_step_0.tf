
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220513180620534517"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt220513180620534517"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
