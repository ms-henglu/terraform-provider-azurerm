
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221019060914448112"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt221019060914448112"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
