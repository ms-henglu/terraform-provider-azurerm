
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240311032535298994"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                         = "accMapsAccount-240311032535298994"
  resource_group_name          = azurerm_resource_group.test.name
  sku_name                     = "G2"
  local_authentication_enabled = false
}
