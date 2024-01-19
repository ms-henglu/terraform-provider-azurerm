
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-240119024903050668"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                            = "acctestDF240119024903050668"
  location                        = azurerm_resource_group.test.location
  resource_group_name             = azurerm_resource_group.test.name
  managed_virtual_network_enabled = true
}
