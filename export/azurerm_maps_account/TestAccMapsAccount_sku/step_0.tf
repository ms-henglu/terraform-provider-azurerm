
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221117231148812471"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-221117231148812471"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "S1"
}
