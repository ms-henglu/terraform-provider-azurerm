
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220826010412316964"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan220826010412316964"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
