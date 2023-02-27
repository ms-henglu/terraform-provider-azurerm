
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230227175716514654"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-230227175716514654"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "G2"
}
