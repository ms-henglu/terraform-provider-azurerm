
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220623223630879842"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-220623223630879842"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "S1"
}
