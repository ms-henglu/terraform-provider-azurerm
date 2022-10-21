
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221021031447650540"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-221021031447650540"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "S0"
}
