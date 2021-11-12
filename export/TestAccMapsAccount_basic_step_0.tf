
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211112020908191060"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-211112020908191060"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "S0"
}
