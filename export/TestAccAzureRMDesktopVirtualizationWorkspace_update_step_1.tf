
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-vdesktop-220916011359086268"
  location = "West US 2"
}

resource "azurerm_virtual_desktop_workspace" "test" {
  name                = "acctestWS22091668"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  friendly_name       = "Acceptance Test!"
  description         = "Acceptance Test by creating acctws220916011359086268"
}
