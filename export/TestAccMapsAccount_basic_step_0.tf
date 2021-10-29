
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211029015831637912"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-211029015831637912"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "S0"
}
