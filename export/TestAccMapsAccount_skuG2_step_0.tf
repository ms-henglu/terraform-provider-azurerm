
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210924004530768585"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-210924004530768585"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "G2"
}
