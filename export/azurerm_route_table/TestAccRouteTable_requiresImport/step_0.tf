
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230613072348648226"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt230613072348648226"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
