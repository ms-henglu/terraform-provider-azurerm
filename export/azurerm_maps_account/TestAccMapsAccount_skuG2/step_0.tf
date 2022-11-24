
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221124181947673879"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-221124181947673879"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "G2"
}
