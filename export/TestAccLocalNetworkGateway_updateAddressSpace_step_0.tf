
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-lngw-211029015948825656"
  location = "West Europe"
}

resource "azurerm_local_network_gateway" "test" {
  name                = "acctestlng-211029015948825656"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  gateway_address     = "127.0.0.1"
}
