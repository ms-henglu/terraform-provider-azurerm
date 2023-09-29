
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230929065414998513"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt230929065414998513"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
