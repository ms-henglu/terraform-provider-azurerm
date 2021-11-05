
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211105030344436404"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan211105030344436404"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
