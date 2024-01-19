
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119022418031140"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-240119022418031140"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "G2"
}
