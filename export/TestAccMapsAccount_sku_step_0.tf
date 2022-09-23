
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220923012055626377"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-220923012055626377"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "S1"
}
