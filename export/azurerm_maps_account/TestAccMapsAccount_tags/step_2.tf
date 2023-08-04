
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230804030255341396"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-230804030255341396"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "S0"

  tags = {
    environment = "testing"
  }
}
