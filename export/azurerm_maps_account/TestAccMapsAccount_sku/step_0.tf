
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230602030754761697"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-230602030754761697"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "S1"
}
