
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-vdesktop-211210034633568905"
  location = "West US 2"
}

resource "azurerm_virtual_desktop_workspace" "test" {
  name                = "acctWS211210034633568905"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
