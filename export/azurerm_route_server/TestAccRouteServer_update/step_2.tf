

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230728030329693037"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvn-230728030329693037"
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
  name                = "acctestpip-230728030329693037"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  allocation_method   = "Static"
  sku                 = "Standard"
}


resource "azurerm_route_server" "test" {
  name                             = "acctestrs-230728030329693037"
  resource_group_name              = azurerm_resource_group.test.name
  location                         = azurerm_resource_group.test.location
  sku                              = "Standard"
  public_ip_address_id             = azurerm_public_ip.test.id
  subnet_id                        = azurerm_subnet.test.id
  branch_to_branch_traffic_enabled = true
}
