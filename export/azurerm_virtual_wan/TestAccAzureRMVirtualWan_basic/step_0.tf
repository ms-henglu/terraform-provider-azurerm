
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112034901677400"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan240112034901677400"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
