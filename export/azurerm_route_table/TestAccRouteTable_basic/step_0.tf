
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221222035101672621"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt221222035101672621"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
