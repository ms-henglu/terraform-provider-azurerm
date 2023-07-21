
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230721012020912011"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-230721012020912011"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "S1"
}
