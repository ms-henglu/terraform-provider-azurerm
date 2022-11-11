
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221111020815122535"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-221111020815122535"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "S0"
}
