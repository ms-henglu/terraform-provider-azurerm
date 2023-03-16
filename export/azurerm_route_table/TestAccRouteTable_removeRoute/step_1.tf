
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230316222026181541"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt230316222026181541"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
