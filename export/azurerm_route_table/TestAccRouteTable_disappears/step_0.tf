
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221221204636256654"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt221221204636256654"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
