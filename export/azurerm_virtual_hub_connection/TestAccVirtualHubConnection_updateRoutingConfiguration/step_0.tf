

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-vhub-230915023921373394"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvirtnet230915023921373394"
  address_space       = ["10.5.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_network_security_group" "test" {
  name                = "acctestnsg230915023921373394"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "acctestsubnet230915023921373394"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.5.1.0/24"]
}

resource "azurerm_subnet_network_security_group_association" "test" {
  subnet_id                 = azurerm_subnet.test.id
  network_security_group_id = azurerm_network_security_group.test.id
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan-230915023921373394"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_virtual_hub" "test" {
  name                = "acctest-VHUB-230915023921373394"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  virtual_wan_id      = azurerm_virtual_wan.test.id
  address_prefix      = "10.0.2.0/24"
}


resource "azurerm_virtual_hub_connection" "test" {
  name                      = "acctest-vhubconn-230915023921373394"
  virtual_hub_id            = azurerm_virtual_hub.test.id
  remote_virtual_network_id = azurerm_virtual_network.test.id

  routing {
    propagated_route_table {
      labels = ["label1", "label2"]
    }

    static_vnet_route {
      name                = "testvnetroute"
      address_prefixes    = ["10.0.3.0/24", "10.0.4.0/24"]
      next_hop_ip_address = "10.0.3.5"
    }

    static_vnet_route {
      name                = "testvnetroute2"
      address_prefixes    = ["10.0.5.0/24"]
      next_hop_ip_address = "10.0.5.5"
    }
  }
}
