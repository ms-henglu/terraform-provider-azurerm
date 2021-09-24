
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210924004645255979"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt210924004645255979"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
