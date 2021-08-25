
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-210825042745282329"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                            = "acctestDF210825042745282329"
  location                        = azurerm_resource_group.test.location
  resource_group_name             = azurerm_resource_group.test.name
  managed_virtual_network_enabled = true
}
