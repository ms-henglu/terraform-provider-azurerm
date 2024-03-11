
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240311032742256184"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan240311032742256184"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
