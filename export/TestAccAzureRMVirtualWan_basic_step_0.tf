
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220527034514246025"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan220527034514246025"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
