
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230519075330898033"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt230519075330898033"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
