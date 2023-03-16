
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-230316221417296545"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                            = "acctestDF230316221417296545"
  location                        = azurerm_resource_group.test.location
  resource_group_name             = azurerm_resource_group.test.name
  managed_virtual_network_enabled = true
}
