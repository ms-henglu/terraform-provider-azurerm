
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220916011725047196"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-220916011725047196"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "S0"

  tags = {
    environment = "testing"
  }
}
