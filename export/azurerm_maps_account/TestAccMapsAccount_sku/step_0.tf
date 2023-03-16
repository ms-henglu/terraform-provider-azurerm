
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230316221908774005"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-230316221908774005"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "S1"
}
