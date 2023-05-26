
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230526085610041857"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt230526085610041857"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
