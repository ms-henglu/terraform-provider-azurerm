
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221124182052974304"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt221124182052974304"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
