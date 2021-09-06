
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210906022551673847"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt210906022551673847"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
