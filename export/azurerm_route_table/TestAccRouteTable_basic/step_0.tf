
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230227033142005690"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt230227033142005690"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
