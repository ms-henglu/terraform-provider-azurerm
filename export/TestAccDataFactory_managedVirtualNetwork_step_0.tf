
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-220429065415692817"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                            = "acctestDF220429065415692817"
  location                        = azurerm_resource_group.test.location
  resource_group_name             = azurerm_resource_group.test.name
  managed_virtual_network_enabled = true
}
