
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220826003006374462"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-220826003006374462"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "G2"
}
