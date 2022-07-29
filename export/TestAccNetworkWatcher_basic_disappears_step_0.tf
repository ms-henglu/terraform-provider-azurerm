
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-watcher-220729033105558439"
  location = "West Europe"
}

resource "azurerm_network_watcher" "test" {
  name                = "acctestNW-220729033105558439"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
