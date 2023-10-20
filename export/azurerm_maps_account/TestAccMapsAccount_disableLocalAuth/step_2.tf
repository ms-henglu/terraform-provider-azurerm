
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231020041423731429"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                         = "accMapsAccount-231020041423731429"
  resource_group_name          = azurerm_resource_group.test.name
  sku_name                     = "G2"
  local_authentication_enabled = true
}
