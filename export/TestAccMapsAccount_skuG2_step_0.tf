
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211021235218653633"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-211021235218653633"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "G2"
}
