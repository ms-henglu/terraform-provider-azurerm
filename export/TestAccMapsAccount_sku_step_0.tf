
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220204060314398946"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-220204060314398946"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "S1"
}
