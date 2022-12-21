
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221221204636272158"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan221221204636272158"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
