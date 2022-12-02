
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-lngw-221202040144946553"
  location = "West Europe"
}

resource "azurerm_local_network_gateway" "test" {
  name                = "acctestlng-221202040144946553"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  gateway_address     = "127.0.0.1"
  address_space       = ["127.0.0.0/8"]

  bgp_settings {
    asn                 = 2468
    bgp_peering_address = "10.104.1.1"
    peer_weight         = 15
  }
}
