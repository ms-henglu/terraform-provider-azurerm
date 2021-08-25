
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210825045003286647"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-210825045003286647"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "S0"
}
