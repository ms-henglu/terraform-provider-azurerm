
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220712042617979909"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt220712042617979909"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
