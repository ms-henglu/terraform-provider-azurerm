
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230227033031686034"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-230227033031686034"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "S1"
}
