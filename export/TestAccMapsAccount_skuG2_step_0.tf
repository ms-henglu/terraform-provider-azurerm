
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220326010830018118"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-220326010830018118"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "G2"
}
