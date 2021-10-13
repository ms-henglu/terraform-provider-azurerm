
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211013072109136311"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-211013072109136311"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "S1"
}
