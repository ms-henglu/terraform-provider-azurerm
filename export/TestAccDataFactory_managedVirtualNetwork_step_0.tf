
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-210928055341236057"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                            = "acctestDF210928055341236057"
  location                        = azurerm_resource_group.test.location
  resource_group_name             = azurerm_resource_group.test.name
  managed_virtual_network_enabled = true
}
