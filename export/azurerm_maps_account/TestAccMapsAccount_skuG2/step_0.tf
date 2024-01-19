
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025349882191"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-240119025349882191"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "G2"
}
