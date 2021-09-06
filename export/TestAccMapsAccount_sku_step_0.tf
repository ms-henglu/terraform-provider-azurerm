
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210906022453415401"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-210906022453415401"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "S1"
}
