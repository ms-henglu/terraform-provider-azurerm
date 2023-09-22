
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922054448916052"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-230922054448916052"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "G2"
}
