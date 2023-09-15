
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230915023745521373"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-230915023745521373"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "G2"
}
