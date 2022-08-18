
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220818235402213627"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-220818235402213627"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "S0"
}
