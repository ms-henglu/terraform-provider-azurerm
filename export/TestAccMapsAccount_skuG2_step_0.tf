
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220811053539308936"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-220811053539308936"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "G2"
}
