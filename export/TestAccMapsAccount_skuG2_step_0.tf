
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220506005952003736"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-220506005952003736"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "G2"
}
