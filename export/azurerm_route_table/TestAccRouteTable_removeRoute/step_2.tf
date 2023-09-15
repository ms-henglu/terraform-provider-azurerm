
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230915023921352190"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt230915023921352190"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  route = []
}
