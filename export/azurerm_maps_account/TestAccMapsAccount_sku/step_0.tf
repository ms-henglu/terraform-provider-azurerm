
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230505050816685855"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-230505050816685855"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "S1"
}
