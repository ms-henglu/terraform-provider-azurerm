
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-watcher-240119025527694166"
  location = "West Europe"
}

resource "azurerm_network_watcher" "test" {
  name                = "acctestNW-240119025527694166"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
