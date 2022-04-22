
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220422025443918719"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-220422025443918719"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "S0"
}
