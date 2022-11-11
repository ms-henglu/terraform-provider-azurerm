
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-vdesktop-221111013438049823"
  location = "West US 2"
}

resource "azurerm_virtual_desktop_workspace" "test" {
  name                = "acctestWS22111123"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  friendly_name       = "Acceptance Test!"
  description         = "Acceptance Test by creating acctws221111013438049823"
}
