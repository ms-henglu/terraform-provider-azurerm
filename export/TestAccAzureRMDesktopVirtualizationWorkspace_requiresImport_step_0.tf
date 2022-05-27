
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-vdesktop-220527034101538838"
  location = "West US 2"
}

resource "azurerm_virtual_desktop_workspace" "test" {
  name                = "acctWS220527034101538838"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
