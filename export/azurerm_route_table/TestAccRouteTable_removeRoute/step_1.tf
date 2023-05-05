
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230505050951350147"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt230505050951350147"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
