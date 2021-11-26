
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211126031511218823"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt211126031511218823"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
