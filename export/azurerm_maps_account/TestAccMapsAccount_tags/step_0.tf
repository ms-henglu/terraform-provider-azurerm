
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230929065239759566"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-230929065239759566"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "S0"
}
