
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221221204636249474"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt221221204636249474"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
