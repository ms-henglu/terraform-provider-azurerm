
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240311032742223203"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt240311032742223203"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
