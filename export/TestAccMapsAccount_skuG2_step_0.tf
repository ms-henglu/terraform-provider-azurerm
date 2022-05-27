
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220527034414938994"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-220527034414938994"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "G2"
}
