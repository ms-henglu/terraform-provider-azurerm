
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-watcher-240315123704061603"
  location = "West Europe"
}

resource "azurerm_network_watcher" "test" {
  name                = "acctestNW-240315123704061603"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    "Source" = "AccTests"
  }
}
