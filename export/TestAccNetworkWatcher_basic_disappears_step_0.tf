
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-watcher-220204093347275017"
  location = "West Europe"
}

resource "azurerm_network_watcher" "test" {
  name                = "acctestNW-220204093347275017"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
