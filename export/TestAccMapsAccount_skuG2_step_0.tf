
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220520040914780470"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-220520040914780470"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "G2"
}
