
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240315123502505925"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                         = "accMapsAccount-240315123502505925"
  resource_group_name          = azurerm_resource_group.test.name
  sku_name                     = "G2"
  local_authentication_enabled = true
}
