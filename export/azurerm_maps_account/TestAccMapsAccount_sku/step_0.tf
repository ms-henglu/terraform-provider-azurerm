
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230113181403486535"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-230113181403486535"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "S1"
}
