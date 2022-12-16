
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-watcher-221216013939229566"
  location = "West Europe"
}

resource "azurerm_network_watcher" "test" {
  name                = "acctestNW-221216013939229566"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
