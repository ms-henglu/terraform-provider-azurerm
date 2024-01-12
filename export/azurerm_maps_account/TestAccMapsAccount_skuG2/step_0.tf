
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112034726827329"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-240112034726827329"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "G2"
}
