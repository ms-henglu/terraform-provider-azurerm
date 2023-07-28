
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230728030329696633"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt230728030329696633"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
