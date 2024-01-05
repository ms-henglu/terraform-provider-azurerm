
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-vdesktop-240105060650202517"
  location = "West US 2"
}

resource "azurerm_virtual_desktop_workspace" "test" {
  name                = "acctWS240105060650202517"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
