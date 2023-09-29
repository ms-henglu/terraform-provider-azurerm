
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-vdesktop-230929064807475256"
  location = "West US 2"
}

resource "azurerm_virtual_desktop_workspace" "test" {
  name                          = "acctestWS23092956"
  location                      = azurerm_resource_group.test.location
  resource_group_name           = azurerm_resource_group.test.name
  friendly_name                 = "Acceptance Test!"
  description                   = "Acceptance Test by creating acctws230929064807475256"
  public_network_access_enabled = false
}
