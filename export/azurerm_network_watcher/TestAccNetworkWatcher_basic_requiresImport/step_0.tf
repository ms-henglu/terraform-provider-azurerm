
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-watcher-221028165326698847"
  location = "West Europe"
}

resource "azurerm_network_watcher" "test" {
  name                = "acctestNW-221028165326698847"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
