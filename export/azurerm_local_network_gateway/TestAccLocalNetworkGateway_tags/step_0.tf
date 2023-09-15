
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-lngw-230915023921304868"
  location = "West Europe"
}

resource "azurerm_local_network_gateway" "test" {
  name                = "acctestlng-230915023921304868"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  gateway_address     = "127.0.0.1"
  address_space       = ["127.0.0.0/8"]

  tags = {
    environment = "acctest"
  }
}
