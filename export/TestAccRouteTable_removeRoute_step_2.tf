
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211008044745635215"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt211008044745635215"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  route = []
}
