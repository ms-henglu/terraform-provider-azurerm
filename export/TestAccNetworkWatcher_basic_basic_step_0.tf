
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-watcher-220630211149404467"
  location = "West Europe"
}

resource "azurerm_network_watcher" "test" {
  name                = "acctestNW-220630211149404467"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
