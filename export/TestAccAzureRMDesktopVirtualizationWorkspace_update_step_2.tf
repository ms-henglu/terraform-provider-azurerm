
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-vdesktop-210830083923779153"
  location = "West US 2"
}

resource "azurerm_virtual_desktop_workspace" "test" {
  name                = "acctWS210830083923779153"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

