



provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025527723168"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvn-240119025527723168"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "RouteServerSubnet"
  virtual_network_name = azurerm_virtual_network.test.name
  resource_group_name  = azurerm_resource_group.test.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_public_ip" "test" {
  name                = "acctestpip-240119025527723168"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  allocation_method   = "Static"
  sku                 = "Standard"
}


resource "azurerm_route_server" "test" {
  name                 = "acctestrs-240119025527723168"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  sku                  = "Standard"
  public_ip_address_id = azurerm_public_ip.test.id
  subnet_id            = azurerm_subnet.test.id
}


resource "azurerm_route_server_bgp_connection" "test" {
  name            = "acctest-rs-bgp-240119025527723168"
  route_server_id = azurerm_route_server.test.id
  peer_asn        = 65501
  peer_ip         = "169.254.21.5"

}


resource "azurerm_route_server_bgp_connection" "import" {
  name            = azurerm_route_server_bgp_connection.test.name
  route_server_id = azurerm_route_server_bgp_connection.test.route_server_id
  peer_asn        = azurerm_route_server_bgp_connection.test.peer_asn
  peer_ip         = azurerm_route_server_bgp_connection.test.peer_ip
}
