
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025527721178"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt240119025527721178"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
