
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231013043818758919"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-231013043818758919"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "S1"
}
