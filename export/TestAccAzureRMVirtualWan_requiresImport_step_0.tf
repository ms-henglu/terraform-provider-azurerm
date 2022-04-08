
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220408051646106339"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan220408051646106339"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
