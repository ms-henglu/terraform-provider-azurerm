
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211203161718312300"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt211203161718312300"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
