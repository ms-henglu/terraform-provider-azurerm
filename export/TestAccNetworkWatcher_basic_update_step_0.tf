
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-watcher-220715004735116591"
  location = "West Europe"
}

resource "azurerm_network_watcher" "test" {
  name                = "acctestNW-220715004735116591"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
