
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-watcher-220429065844283824"
  location = "West Europe"
}

resource "azurerm_network_watcher" "test" {
  name                = "acctestNW-220429065844283824"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
