
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221028165326713933"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt221028165326713933"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
