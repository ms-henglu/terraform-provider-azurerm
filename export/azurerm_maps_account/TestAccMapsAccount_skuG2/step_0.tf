
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105064151289426"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-240105064151289426"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "G2"
}
