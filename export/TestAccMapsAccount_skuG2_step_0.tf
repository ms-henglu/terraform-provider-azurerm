
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211126031413913768"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-211126031413913768"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "G2"
}
