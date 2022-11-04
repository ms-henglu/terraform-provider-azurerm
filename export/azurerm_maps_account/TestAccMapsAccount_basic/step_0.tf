
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221104005638942325"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-221104005638942325"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "S0"
}
