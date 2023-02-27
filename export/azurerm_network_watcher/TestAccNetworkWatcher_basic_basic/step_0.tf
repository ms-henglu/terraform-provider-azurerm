
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-watcher-230227033141973431"
  location = "West Europe"
}

resource "azurerm_network_watcher" "test" {
  name                = "acctestNW-230227033141973431"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
