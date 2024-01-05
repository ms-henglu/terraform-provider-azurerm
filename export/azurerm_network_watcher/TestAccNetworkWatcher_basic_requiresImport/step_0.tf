
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-watcher-240105061256852843"
  location = "West Europe"
}

resource "azurerm_network_watcher" "test" {
  name                = "acctestNW-240105061256852843"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
