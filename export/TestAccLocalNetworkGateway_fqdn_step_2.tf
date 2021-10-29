
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-network-211029015948824661"
  location = "West Europe"
}

resource "azurerm_local_network_gateway" "test" {
  name                = "acctestlng-211029015948824661"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  gateway_fqdn        = "www.bar.com"
  address_space       = ["127.0.0.0/8"]
}
