
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922054621754159"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt230922054621754159"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
