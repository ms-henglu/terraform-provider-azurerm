
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211119051116897597"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-211119051116897597"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "G2"
}
