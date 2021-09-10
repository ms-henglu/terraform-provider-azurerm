
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210910021620295496"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-210910021620295496"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "S1"
}
