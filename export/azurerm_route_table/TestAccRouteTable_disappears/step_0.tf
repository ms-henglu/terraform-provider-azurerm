
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240315123704098527"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt240315123704098527"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
