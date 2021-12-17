
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211217035532677326"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-211217035532677326"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "G2"
}
