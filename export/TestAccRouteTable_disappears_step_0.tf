
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220107034256729513"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt220107034256729513"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
