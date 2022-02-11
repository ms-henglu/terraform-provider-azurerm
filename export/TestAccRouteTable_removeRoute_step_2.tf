
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220211131004311354"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt220211131004311354"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  route = []
}
