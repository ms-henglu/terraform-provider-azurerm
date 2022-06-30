
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-220630223618033721"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                            = "acctestDF220630223618033721"
  location                        = azurerm_resource_group.test.location
  resource_group_name             = azurerm_resource_group.test.name
  managed_virtual_network_enabled = true
}
