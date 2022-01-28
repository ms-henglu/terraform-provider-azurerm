
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220128052857329212"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt220128052857329212"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  route = []
}
