
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220513023510738173"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-220513023510738173"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "S0"
}
