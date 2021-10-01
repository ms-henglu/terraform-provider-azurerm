
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211001020958613390"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-211001020958613390"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "S0"
}
