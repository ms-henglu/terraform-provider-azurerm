
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230825024857457433"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-230825024857457433"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "S0"
}
