
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230630033527635843"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-230630033527635843"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "S0"
}
