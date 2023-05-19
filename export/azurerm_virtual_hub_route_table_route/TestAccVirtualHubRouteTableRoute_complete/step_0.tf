

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-VHUB-230519075330923915"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctest-VNET-230519075330923915"
  address_space       = ["10.5.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_network_security_group" "test" {
  name                = "acctest-NSG-230519075330923915"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "acctest-SUBNET-230519075330923915"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.5.1.0/24"]
}

resource "azurerm_subnet_network_security_group_association" "test" {
  subnet_id                 = azurerm_subnet.test.id
  network_security_group_id = azurerm_network_security_group.test.id
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctest-VWAN-230519075330923915"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_virtual_hub" "test" {
  name                = "acctest-VHUB-230519075330923915"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  virtual_wan_id      = azurerm_virtual_wan.test.id
  address_prefix      = "10.0.2.0/24"
}

resource "azurerm_virtual_hub_connection" "test" {
  name                      = "acctest-VHUBCONN-230519075330923915"
  virtual_hub_id            = azurerm_virtual_hub.test.id
  remote_virtual_network_id = azurerm_virtual_network.test.id
}

resource "azurerm_virtual_hub_route_table" "test" {
  name           = "acctest-RouteTable-230519075330923915"
  virtual_hub_id = azurerm_virtual_hub.test.id
  labels         = ["Label1"]
}


resource "azurerm_virtual_hub_route_table_route" "test" {
  route_table_id = azurerm_virtual_hub_route_table.test.id

  name = "acctest-Route-230519075330923915"

  destinations_type = "CIDR"
  destinations      = ["10.0.0.0/16", "10.1.0.0/16"]
  next_hop_type     = "ResourceId"
  next_hop          = azurerm_virtual_hub_connection.test.id
}

resource "azurerm_virtual_hub_route_table_route" "test_2" {
  route_table_id = azurerm_virtual_hub_route_table.test.id

  name = "acctest-Route-230519075330923915-2"

  destinations_type = "CIDR"
  destinations      = ["10.2.0.0/16"]
  next_hop_type     = "ResourceId"
  next_hop          = azurerm_virtual_hub_connection.test.id
}

// test a route on the default route table
resource "azurerm_virtual_hub_route_table_route" "test_3" {
  route_table_id = azurerm_virtual_hub.test.default_route_table_id

  name = "acctest-Route-230519075330923915-3"

  destinations_type = "CIDR"
  destinations      = ["10.3.0.0/16"]
  next_hop_type     = "ResourceId"
  next_hop          = azurerm_virtual_hub_connection.test.id
}
