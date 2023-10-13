
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231013043954346845"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt231013043954346845"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
