
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210825031845656607"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-210825031845656607"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "G2"
}
