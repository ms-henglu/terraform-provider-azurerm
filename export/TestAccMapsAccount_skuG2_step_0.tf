
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220506020155269747"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-220506020155269747"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "G2"
}
