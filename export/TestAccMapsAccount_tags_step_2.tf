
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211015014458177086"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-211015014458177086"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "S0"

  tags = {
    environment = "testing"
  }
}
