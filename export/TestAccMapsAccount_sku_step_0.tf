
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221019054616347584"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-221019054616347584"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "S1"
}
