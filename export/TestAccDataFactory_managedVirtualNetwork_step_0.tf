
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-210924004140115841"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                            = "acctestDF210924004140115841"
  location                        = azurerm_resource_group.test.location
  resource_group_name             = azurerm_resource_group.test.name
  managed_virtual_network_enabled = true
}
