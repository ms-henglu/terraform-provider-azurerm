
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210928075650760354"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-210928075650760354"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "S1"
}
