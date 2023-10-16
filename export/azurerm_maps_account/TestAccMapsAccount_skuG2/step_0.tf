
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016034252699101"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-231016034252699101"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "G2"
}
