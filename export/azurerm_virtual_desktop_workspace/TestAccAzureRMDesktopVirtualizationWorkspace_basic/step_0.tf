
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-vdesktop-221222034553788775"
  location = "West US 2"
}

resource "azurerm_virtual_desktop_workspace" "test" {
  name                = "acctWS221222034553788775"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
