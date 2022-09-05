
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220905050254818565"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan220905050254818565"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
