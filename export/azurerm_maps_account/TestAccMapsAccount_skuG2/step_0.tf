
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230804030255342305"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-230804030255342305"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "G2"
}
