
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230407023723353184"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-230407023723353184"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "S1"
}
