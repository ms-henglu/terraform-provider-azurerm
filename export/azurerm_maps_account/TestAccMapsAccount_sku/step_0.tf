
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231020041423735878"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-231020041423735878"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "G2"
}
