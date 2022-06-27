
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220627134729994767"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-220627134729994767"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "S1"
}
