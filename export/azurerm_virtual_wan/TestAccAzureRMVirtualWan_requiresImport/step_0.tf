
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230630033653939665"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan230630033653939665"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
