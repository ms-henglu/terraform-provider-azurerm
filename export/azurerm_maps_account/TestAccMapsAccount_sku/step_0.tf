
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230519075151628341"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-230519075151628341"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "S1"
}
