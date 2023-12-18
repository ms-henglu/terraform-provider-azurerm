
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231218072122205253"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                         = "accMapsAccount-231218072122205253"
  resource_group_name          = azurerm_resource_group.test.name
  sku_name                     = "G2"
  local_authentication_enabled = false
}
