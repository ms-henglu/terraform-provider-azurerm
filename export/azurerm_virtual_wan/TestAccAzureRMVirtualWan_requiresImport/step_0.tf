
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240315123704148106"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan240315123704148106"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
