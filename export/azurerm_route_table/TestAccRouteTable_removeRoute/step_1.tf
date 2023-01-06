
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230106034829585273"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt230106034829585273"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
