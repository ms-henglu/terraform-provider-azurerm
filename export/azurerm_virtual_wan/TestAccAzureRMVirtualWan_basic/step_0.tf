
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221104005727253491"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan221104005727253491"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
