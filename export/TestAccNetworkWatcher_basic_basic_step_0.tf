
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-watcher-211105030344407638"
  location = "West Europe"
}

resource "azurerm_network_watcher" "test" {
  name                = "acctestNW-211105030344407638"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
