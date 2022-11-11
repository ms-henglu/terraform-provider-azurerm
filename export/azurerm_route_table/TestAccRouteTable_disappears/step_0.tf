
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221111014003170265"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt221111014003170265"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
