
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230505050816688053"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-230505050816688053"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "G2"
}
