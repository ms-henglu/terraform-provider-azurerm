
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240315123502508499"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-240315123502508499"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "G2"
}
