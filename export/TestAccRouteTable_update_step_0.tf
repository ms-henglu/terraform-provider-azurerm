
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220812015532263659"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt220812015532263659"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
