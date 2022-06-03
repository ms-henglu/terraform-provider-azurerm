
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220603022440199849"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan220603022440199849"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
