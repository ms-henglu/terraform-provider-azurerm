
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221111020925393879"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan221111020925393879"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
