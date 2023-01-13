
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230113181403487455"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-230113181403487455"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "G2"
}
