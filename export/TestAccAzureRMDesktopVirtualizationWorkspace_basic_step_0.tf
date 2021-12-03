
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-vdesktop-211203161322400796"
  location = "West US 2"
}

resource "azurerm_virtual_desktop_workspace" "test" {
  name                = "acctWS211203161322400796"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
