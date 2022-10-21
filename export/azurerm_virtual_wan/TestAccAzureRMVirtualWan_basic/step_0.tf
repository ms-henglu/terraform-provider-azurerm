
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221021034418191264"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan221021034418191264"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
