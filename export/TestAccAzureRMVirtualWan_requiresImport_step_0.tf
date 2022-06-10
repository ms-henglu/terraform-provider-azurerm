
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220610093039291579"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan220610093039291579"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
