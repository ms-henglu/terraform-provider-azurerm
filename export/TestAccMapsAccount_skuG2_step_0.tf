
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220324163628588236"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-220324163628588236"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "G2"
}
