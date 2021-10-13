
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-vdesktop-211013071807354798"
  location = "West US 2"
}

resource "azurerm_virtual_desktop_workspace" "test" {
  name                = "acctWS211013071807354798"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

