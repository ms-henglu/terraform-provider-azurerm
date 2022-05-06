
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-watcher-220506020301484098"
  location = "West Europe"
}

resource "azurerm_network_watcher" "test" {
  name                = "acctestNW-220506020301484098"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
