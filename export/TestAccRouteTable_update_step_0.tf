
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211105040250090704"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt211105040250090704"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
