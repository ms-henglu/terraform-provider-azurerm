
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-watcher-230810143940990665"
  location = "West Europe"
}

resource "azurerm_network_watcher" "test" {
  name                = "acctestNW-230810143940990665"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
