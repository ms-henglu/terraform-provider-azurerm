
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230818024518213534"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan230818024518213534"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
