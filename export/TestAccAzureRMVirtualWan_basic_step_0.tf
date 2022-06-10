
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220610093039290206"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan220610093039290206"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
