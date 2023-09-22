
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922054448918717"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                         = "accMapsAccount-230922054448918717"
  resource_group_name          = azurerm_resource_group.test.name
  sku_name                     = "S0"
  local_authentication_enabled = false
}
