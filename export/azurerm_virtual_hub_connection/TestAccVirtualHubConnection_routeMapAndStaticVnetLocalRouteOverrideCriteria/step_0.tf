

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-vhub-240311032742231154"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvirtnet240311032742231154"
  address_space       = ["10.5.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_network_security_group" "test" {
  name                = "acctestnsg240311032742231154"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "acctestsubnet240311032742231154"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.5.1.0/24"]
}

resource "azurerm_subnet_network_security_group_association" "test" {
  subnet_id                 = azurerm_subnet.test.id
  network_security_group_id = azurerm_network_security_group.test.id
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan-240311032742231154"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_virtual_hub" "test" {
  name                = "acctest-VHUB-240311032742231154"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  virtual_wan_id      = azurerm_virtual_wan.test.id
  address_prefix      = "10.0.2.0/24"
}


resource "azurerm_route_map" "test" {
  name           = "acctestrm-pyibl"
  virtual_hub_id = azurerm_virtual_hub.test.id

  rule {
    name                 = "rule1"
    next_step_if_matched = "Continue"

    action {
      type = "Add"

      parameter {
        as_path = ["22334"]
      }
    }

    match_criterion {
      match_condition = "Contains"
      route_prefix    = ["10.0.0.0/8"]
    }
  }
}

resource "azurerm_route_map" "test2" {
  name           = "acctestrmn-pyibl"
  virtual_hub_id = azurerm_virtual_hub.test.id

  rule {
    name                 = "rule1"
    next_step_if_matched = "Continue"

    action {
      type = "Add"

      parameter {
        as_path = ["22334"]
      }
    }

    match_criterion {
      match_condition = "Contains"
      route_prefix    = ["10.0.0.0/8"]
    }
  }
}

resource "azurerm_virtual_hub_connection" "test" {
  name                      = "acctest-vhubconn-240311032742231154"
  virtual_hub_id            = azurerm_virtual_hub.test.id
  remote_virtual_network_id = azurerm_virtual_network.test.id

  routing {
    inbound_route_map_id                      = azurerm_route_map.test.id
    outbound_route_map_id                     = azurerm_route_map.test2.id
    static_vnet_local_route_override_criteria = "Equal"

    propagated_route_table {
      labels = ["label3"]
    }

    static_vnet_route {
      name                = "testvnetroute6"
      address_prefixes    = ["10.0.6.0/24", "10.0.7.0/24"]
      next_hop_ip_address = "10.0.6.5"
    }
  }
}
