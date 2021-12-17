
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211217035641175843"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan211217035641175843"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
