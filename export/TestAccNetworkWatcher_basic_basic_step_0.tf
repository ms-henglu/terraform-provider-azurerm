
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-watcher-211001054032485032"
  location = "West Europe"
}

resource "azurerm_network_watcher" "test" {
  name                = "acctestNW-211001054032485032"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
