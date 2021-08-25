

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210825031936338944"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvn-210825031936338944"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "test" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefix       = "10.0.2.0/24"
}


resource "azurerm_network_interface" "test" {
  name                    = "acctestni-210825031936338944"
  location                = azurerm_resource_group.test.location
  resource_group_name     = azurerm_resource_group.test.name
  enable_ip_forwarding    = true
  internal_dns_name_label = "acctestni-b44yh"

  dns_servers = [
    "10.0.0.5",
    "10.0.0.6"
  ]

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.test.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    env = "Test"
  }
}
