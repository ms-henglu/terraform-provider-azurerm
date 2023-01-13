
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230113181502811141"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt230113181502811141"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
