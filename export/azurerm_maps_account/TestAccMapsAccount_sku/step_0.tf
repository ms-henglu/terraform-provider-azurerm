
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230512011020715791"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-230512011020715791"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "S1"
}
