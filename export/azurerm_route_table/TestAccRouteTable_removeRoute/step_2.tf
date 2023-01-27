
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230127045836050601"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt230127045836050601"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  route = []
}
