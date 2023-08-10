
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230810143941033999"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvn-230810143941033999"
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
  name                = "acctest-230810143941033999"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
}

resource "azurerm_virtual_network_gateway" "test" {
  name                = "acctest-230810143941033999"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  type                       = "Vpn"
  vpn_type                   = "RouteBased"
  sku                        = "VpnGw1AZ"
  private_ip_address_enabled = true

  custom_route {
    address_prefixes = [
      "101.168.0.6/32"
    ]
  }

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.test.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.test.id
  }
}
