
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220506020301529298"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan220506020301529298"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
