
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230929065415011271"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvn-230929065415011271"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "test" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "test" {
  name                = "acctestpip-230929065415011271"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "test" {
  name                = "acctestvnetgw-230929065415011271"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  type     = "Vpn"
  vpn_type = "RouteBased"
  sku      = "Basic"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.test.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.test.id
  }
}

data "azurerm_virtual_network_gateway" "test" {
  name                = azurerm_virtual_network_gateway.test.name
  resource_group_name = azurerm_virtual_network_gateway.test.resource_group_name
}

resource "azurerm_local_network_gateway" "test" {
  name                = "acctestlocalnetworkgw-230929065415011271"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  gateway_address = "168.62.225.23"
  address_space   = ["10.1.1.0/24"]
}

resource "azurerm_virtual_network_gateway_nat_rule" "test" {
  name                       = "acctestvnetgwegressnatrule-230929065415011271"
  resource_group_name        = azurerm_resource_group.test.name
  virtual_network_gateway_id = data.azurerm_virtual_network_gateway.test.id
  mode                       = "EgressSnat"
  type                       = "Dynamic"
  ip_configuration_id        = data.azurerm_virtual_network_gateway.test.ip_configuration.0.id

  external_mapping {
    address_space = "10.1.0.0/26"
  }

  internal_mapping {
    address_space = "10.2.0.0/26"
  }
}

resource "azurerm_virtual_network_gateway_nat_rule" "test2" {
  name                       = "acctestvnetgwingressnatrule-230929065415011271"
  resource_group_name        = azurerm_resource_group.test.name
  virtual_network_gateway_id = data.azurerm_virtual_network_gateway.test.id
  mode                       = "IngressSnat"
  type                       = "Dynamic"
  ip_configuration_id        = data.azurerm_virtual_network_gateway.test.ip_configuration.0.id

  external_mapping {
    address_space = "10.7.0.0/26"
  }

  internal_mapping {
    address_space = "10.8.0.0/26"
  }
}

resource "azurerm_virtual_network_gateway_connection" "test" {
  name                = "acctestvnetgwconn-230929065415011271"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.test.id
  local_network_gateway_id   = azurerm_local_network_gateway.test.id

  egress_nat_rule_ids  = [azurerm_virtual_network_gateway_nat_rule.test.id]
  ingress_nat_rule_ids = [azurerm_virtual_network_gateway_nat_rule.test2.id]
}
