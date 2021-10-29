
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-watcher-211029015948841950"
  location = "West Europe"
}

resource "azurerm_network_watcher" "test" {
  name                = "acctestNW-211029015948841950"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
