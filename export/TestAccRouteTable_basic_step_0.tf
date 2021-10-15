
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211015014936452368"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt211015014936452368"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
