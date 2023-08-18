
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230818024350662590"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-230818024350662590"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "S0"
}
