
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210928075747638440"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt210928075747638440"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
