
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210910021721142518"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt210910021721142518"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  route = []
}
