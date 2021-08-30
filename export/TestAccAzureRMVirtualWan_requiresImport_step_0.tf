
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210830084312707081"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan210830084312707081"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
