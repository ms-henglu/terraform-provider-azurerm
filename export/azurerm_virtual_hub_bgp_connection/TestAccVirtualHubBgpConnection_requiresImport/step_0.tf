

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-VHub-231016034431034992"
  location = "West Europe"
}

resource "azurerm_virtual_hub" "test" {
  name                = "acctest-VHub-231016034431034992"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Standard"
}

resource "azurerm_public_ip" "test" {
  name                = "acctest-PIP-231016034431034992"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctest-VNet-231016034431034992"
  address_space       = ["10.5.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "RouteServerSubnet"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.5.1.0/24"]
}

resource "azurerm_virtual_hub_ip" "test" {
  name                         = "acctest-VHub-IP-231016034431034992"
  virtual_hub_id               = azurerm_virtual_hub.test.id
  private_ip_address           = "10.5.1.18"
  private_ip_allocation_method = "Static"
  public_ip_address_id         = azurerm_public_ip.test.id
  subnet_id                    = azurerm_subnet.test.id
}


resource "azurerm_virtual_hub_bgp_connection" "test" {
  name           = "acctest-VHub-BgpConnection-231016034431034992"
  virtual_hub_id = azurerm_virtual_hub.test.id
  peer_asn       = 65514
  peer_ip        = "169.254.21.5"

  depends_on = [azurerm_virtual_hub_ip.test]
}
