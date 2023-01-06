
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230106031701219890"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-230106031701219890"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "G2"
}
