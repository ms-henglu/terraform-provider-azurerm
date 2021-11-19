
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-vdesktop-211119050805566728"
  location = "West US 2"
}

resource "azurerm_virtual_desktop_workspace" "test" {
  name                = "acctWS211119050805566728"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

