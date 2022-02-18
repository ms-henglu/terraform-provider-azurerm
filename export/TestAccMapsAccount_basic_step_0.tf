
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220218071003666256"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-220218071003666256"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "S0"
}
