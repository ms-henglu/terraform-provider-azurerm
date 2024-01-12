
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112224824535366"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-240112224824535366"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "G2"
}
