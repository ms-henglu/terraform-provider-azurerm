
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220812015417383748"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-220812015417383748"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "S0"
}
