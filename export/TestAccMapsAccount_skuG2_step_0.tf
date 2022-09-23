
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220923012055629441"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-220923012055629441"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "G2"
}
