
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211105030344424746"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt211105030344424746"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
