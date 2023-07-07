

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-watcher-230707010742393532"
  location = "West Europe"
}

resource "azurerm_network_watcher" "test" {
  name                = "acctestNW-230707010742393532"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_network_watcher" "import" {
  name                = azurerm_network_watcher.test.name
  location            = azurerm_network_watcher.test.location
  resource_group_name = azurerm_network_watcher.test.resource_group_name
}
