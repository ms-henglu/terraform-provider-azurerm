
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210917031918846311"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-210917031918846311"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "S0"
}
