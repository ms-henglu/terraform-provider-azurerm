
variable "random1" {
  default = "230915023921372952"
}

variable "random2" {
  default = "230915023921370171"
}

variable "shared_key" {
  default = "4-v3ry-53cr37-1p53c-5h4r3d-k3y"
}

resource "azurerm_resource_group" "test_1" {
  name     = "acctestRG-${var.random1}"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test_1" {
  name                = "acctestvn-${var.random1}"
  location            = azurerm_resource_group.test_1.location
  resource_group_name = azurerm_resource_group.test_1.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "test_1" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.test_1.name
  virtual_network_name = azurerm_virtual_network.test_1.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "test_1" {
  name                = "acctest-${var.random1}"
  location            = azurerm_resource_group.test_1.location
  resource_group_name = azurerm_resource_group.test_1.name
  allocation_method   = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "test_1" {
  name                = "acctest-${var.random1}"
  location            = azurerm_resource_group.test_1.location
  resource_group_name = azurerm_resource_group.test_1.name

  type     = "Vpn"
  vpn_type = "RouteBased"
  sku      = "Basic"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.test_1.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.test_1.id
  }
}

resource "azurerm_virtual_network_gateway_connection" "test_1" {
  name                = "acctest-${var.random1}"
  location            = azurerm_resource_group.test_1.location
  resource_group_name = azurerm_resource_group.test_1.name

  type                            = "Vnet2Vnet"
  virtual_network_gateway_id      = azurerm_virtual_network_gateway.test_1.id
  peer_virtual_network_gateway_id = azurerm_virtual_network_gateway.test_2.id

  shared_key = var.shared_key
}

resource "azurerm_resource_group" "test_2" {
  name     = "acctestRG-${var.random2}"
  location = "West US 2"
}

resource "azurerm_virtual_network" "test_2" {
  name                = "acctest-${var.random2}"
  location            = azurerm_resource_group.test_2.location
  resource_group_name = azurerm_resource_group.test_2.name
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "test_2" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.test_2.name
  virtual_network_name = azurerm_virtual_network.test_2.name
  address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_public_ip" "test_2" {
  name                = "acctest-${var.random2}"
  location            = azurerm_resource_group.test_2.location
  resource_group_name = azurerm_resource_group.test_2.name
  allocation_method   = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "test_2" {
  name                = "acctest-${var.random2}"
  location            = azurerm_resource_group.test_2.location
  resource_group_name = azurerm_resource_group.test_2.name

  type     = "Vpn"
  vpn_type = "RouteBased"
  sku      = "Basic"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.test_2.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.test_2.id
  }
}

resource "azurerm_virtual_network_gateway_connection" "test_2" {
  name                = "acctest-${var.random2}"
  location            = azurerm_resource_group.test_2.location
  resource_group_name = azurerm_resource_group.test_2.name

  type                            = "Vnet2Vnet"
  virtual_network_gateway_id      = azurerm_virtual_network_gateway.test_2.id
  peer_virtual_network_gateway_id = azurerm_virtual_network_gateway.test_1.id

  shared_key = var.shared_key
}
