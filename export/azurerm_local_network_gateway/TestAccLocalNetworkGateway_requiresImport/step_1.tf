

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-lngw-240105064326573977"
  location = "West Europe"
}

resource "azurerm_local_network_gateway" "test" {
  name                = "acctestlng-240105064326573977"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  gateway_address     = "127.0.0.1"
  address_space       = ["127.0.0.0/8"]
}


resource "azurerm_local_network_gateway" "import" {
  name                = azurerm_local_network_gateway.test.name
  location            = azurerm_local_network_gateway.test.location
  resource_group_name = azurerm_local_network_gateway.test.resource_group_name
  gateway_address     = "127.0.0.1"
  address_space       = ["127.0.0.0/8"]
}
