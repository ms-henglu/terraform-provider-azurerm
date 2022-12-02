
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221202040025735641"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-221202040025735641"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "S1"
}
