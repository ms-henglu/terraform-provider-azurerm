
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221111020815128138"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-221111020815128138"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "S0"
}
