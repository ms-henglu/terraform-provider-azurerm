
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-watcher-220826010412257587"
  location = "West Europe"
}

resource "azurerm_network_watcher" "test" {
  name                = "acctestNW-220826010412257587"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
