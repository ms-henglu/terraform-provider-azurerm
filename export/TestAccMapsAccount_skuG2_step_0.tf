
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211105040141325279"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-211105040141325279"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "G2"
}
