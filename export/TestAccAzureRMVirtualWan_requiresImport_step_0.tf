
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220826003111939317"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan220826003111939317"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
