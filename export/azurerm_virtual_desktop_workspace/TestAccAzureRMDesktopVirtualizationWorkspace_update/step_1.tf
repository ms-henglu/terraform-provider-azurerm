
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-vdesktop-231016033814159237"
  location = "West US 2"
}

resource "azurerm_virtual_desktop_workspace" "test" {
  name                          = "acctestWS23101637"
  location                      = azurerm_resource_group.test.location
  resource_group_name           = azurerm_resource_group.test.name
  friendly_name                 = "Acceptance Test!"
  description                   = "Acceptance Test by creating acctws231016033814159237"
  public_network_access_enabled = false
}
