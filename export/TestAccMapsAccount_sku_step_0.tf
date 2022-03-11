
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220311032804245258"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-220311032804245258"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "S1"
}
