
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221222034957101943"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-221222034957101943"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "S0"
}
