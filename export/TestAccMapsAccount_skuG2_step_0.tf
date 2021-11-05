
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211105030238586385"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-211105030238586385"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "G2"
}
