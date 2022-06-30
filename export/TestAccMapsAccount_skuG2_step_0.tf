
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220630211050472587"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-220630211050472587"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "G2"
}
