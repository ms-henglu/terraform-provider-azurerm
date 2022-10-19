
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-watcher-221019054722373114"
  location = "West Europe"
}

resource "azurerm_network_watcher" "test" {
  name                = "acctestNW-221019054722373114"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
