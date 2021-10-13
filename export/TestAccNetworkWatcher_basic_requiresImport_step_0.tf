
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-watcher-211013072215400565"
  location = "West Europe"
}

resource "azurerm_network_watcher" "test" {
  name                = "acctestNW-211013072215400565"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
