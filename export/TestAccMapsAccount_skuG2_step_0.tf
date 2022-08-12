
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220812015417386175"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-220812015417386175"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "G2"
}
