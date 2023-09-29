
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230929065239757610"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-230929065239757610"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "G2"
}
