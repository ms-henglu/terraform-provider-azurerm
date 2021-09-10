
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210910021721166949"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan210910021721166949"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
