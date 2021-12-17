
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211217075627717353"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan211217075627717353"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
