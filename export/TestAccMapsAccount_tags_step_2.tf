
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220121044725717813"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-220121044725717813"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "S0"

  tags = {
    environment = "testing"
  }
}
