
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230313021634734425"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt230313021634734425"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
