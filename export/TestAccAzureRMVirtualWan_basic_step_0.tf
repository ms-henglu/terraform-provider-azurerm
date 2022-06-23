
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220623223730210784"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan220623223730210784"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
