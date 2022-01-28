
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220128052750235922"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-220128052750235922"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "G2"
}
