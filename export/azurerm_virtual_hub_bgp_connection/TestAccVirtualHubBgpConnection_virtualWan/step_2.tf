

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-vhub-230512011140788726"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvirtnet230512011140788726"
  address_space       = ["10.5.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_network_security_group" "test" {
  name                = "acctestnsg230512011140788726"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "acctestsubnet230512011140788726"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.5.1.0/24"]
}

resource "azurerm_subnet_network_security_group_association" "test" {
  subnet_id                 = azurerm_subnet.test.id
  network_security_group_id = azurerm_network_security_group.test.id
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan-230512011140788726"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_virtual_hub" "test" {
  name                = "acctest-VHUB-230512011140788726"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  virtual_wan_id      = azurerm_virtual_wan.test.id
  address_prefix      = "10.0.2.0/24"
}


resource "azurerm_virtual_hub_connection" "test" {
  name                      = "acctestbasicvhubconn-230512011140788726"
  virtual_hub_id            = azurerm_virtual_hub.test.id
  remote_virtual_network_id = azurerm_virtual_network.test.id
}

resource "azurerm_virtual_network" "test2" {
  name                = "acctestvirtnet2230512011140788726"
  address_space       = ["10.6.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_network_security_group" "test2" {
  name                = "acctestnsg2230512011140788726"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test2" {
  name                 = "acctestsubnet2230512011140788726"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test2.name
  address_prefixes     = ["10.6.1.0/24"]
}

resource "azurerm_subnet_network_security_group_association" "test2" {
  subnet_id                 = azurerm_subnet.test2.id
  network_security_group_id = azurerm_network_security_group.test2.id
}

resource "azurerm_virtual_hub" "test2" {
  name                = "acctest-VHUB2-230512011140788726"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  virtual_wan_id      = azurerm_virtual_wan.test.id
  address_prefix      = "10.1.2.0/24"
}

resource "azurerm_virtual_hub_connection" "test2" {
  name                      = "acctestbasicvhubconn2-230512011140788726"
  virtual_hub_id            = azurerm_virtual_hub.test2.id
  remote_virtual_network_id = azurerm_virtual_network.test2.id
}

resource "azurerm_virtual_hub_bgp_connection" "test" {
  name                          = "acctest-VHub-BgpConnection-230512011140788726"
  virtual_hub_id                = azurerm_virtual_hub.test2.id
  peer_asn                      = 65514
  peer_ip                       = "10.6.0.1"
  virtual_network_connection_id = azurerm_virtual_hub_connection.test2.id
}
