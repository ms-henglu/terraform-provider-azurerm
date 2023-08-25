

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-vdesktop-230825024436690763"
  location = "West US 2"
}

resource "azurerm_virtual_desktop_workspace" "test" {
  name                = "acctWS230825024436690763"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_virtual_desktop_workspace" "import" {
  name                = azurerm_virtual_desktop_workspace.test.name
  location            = azurerm_virtual_desktop_workspace.test.location
  resource_group_name = azurerm_virtual_desktop_workspace.test.resource_group_name
}
