
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-watcher-230512004521299520"
  location = "West Europe"
}

resource "azurerm_network_watcher" "test" {
  name                = "acctestNW-230512004521299520"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
