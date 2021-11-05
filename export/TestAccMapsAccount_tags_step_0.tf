
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211105030238584841"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-211105030238584841"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "S0"
}
