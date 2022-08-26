
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-vdesktop-220826002635210808"
  location = "West US 2"
}

resource "azurerm_virtual_desktop_workspace" "test" {
  name                = "acctestWS22082608"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  friendly_name       = "Acceptance Test!"
  description         = "Acceptance Test by creating acctws220826002635210808"
}
