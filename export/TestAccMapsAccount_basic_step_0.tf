
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210825025953577243"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-210825025953577243"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "S0"
}
