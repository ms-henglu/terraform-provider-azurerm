
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-vdesktop-230810143345987373"
  location = "West US 2"
}

resource "azurerm_virtual_desktop_workspace" "test" {
  name                = "acctWS230810143345987373"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
