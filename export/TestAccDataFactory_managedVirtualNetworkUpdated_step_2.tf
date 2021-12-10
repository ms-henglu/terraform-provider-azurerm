
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-211210034558600965"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                            = "acctestDF211210034558600965"
  location                        = azurerm_resource_group.test.location
  resource_group_name             = azurerm_resource_group.test.name
  managed_virtual_network_enabled = true
}
