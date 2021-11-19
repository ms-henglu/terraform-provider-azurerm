
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-211119050737608359"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                            = "acctestDF211119050737608359"
  location                        = azurerm_resource_group.test.location
  resource_group_name             = azurerm_resource_group.test.name
  managed_virtual_network_enabled = true
}
