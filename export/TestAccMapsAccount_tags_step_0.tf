
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210825043030750055"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-210825043030750055"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "S0"
}
