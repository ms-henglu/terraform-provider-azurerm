
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-230407023248956512"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                            = "acctestDF230407023248956512"
  location                        = azurerm_resource_group.test.location
  resource_group_name             = azurerm_resource_group.test.name
  managed_virtual_network_enabled = true
}
