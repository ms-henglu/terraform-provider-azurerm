
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230203063724655347"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-230203063724655347"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "G2"
}
