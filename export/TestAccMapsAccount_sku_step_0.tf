
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220408051539055595"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-220408051539055595"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "S1"
}
