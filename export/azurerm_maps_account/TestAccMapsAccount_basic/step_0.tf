
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221019060826252141"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-221019060826252141"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "S0"
}
