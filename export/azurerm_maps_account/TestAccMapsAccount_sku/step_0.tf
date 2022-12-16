
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221216013831133756"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-221216013831133756"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "S1"
}
