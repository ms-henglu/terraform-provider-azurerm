
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230120054937314194"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt230120054937314194"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  route = []
}
