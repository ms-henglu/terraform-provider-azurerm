
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112224958323030"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan240112224958323030"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
