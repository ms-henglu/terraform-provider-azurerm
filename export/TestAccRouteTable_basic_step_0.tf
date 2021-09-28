
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210928055740871687"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt210928055740871687"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
