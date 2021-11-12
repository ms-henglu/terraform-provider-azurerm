
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211112020908197151"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-211112020908197151"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "G2"
}
