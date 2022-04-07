
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220407231205765622"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-220407231205765622"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "S1"
}
