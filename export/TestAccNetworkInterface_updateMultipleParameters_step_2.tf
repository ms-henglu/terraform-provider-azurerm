

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210924004645238753"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvn-210924004645238753"
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
  name                    = "acctestni-210924004645238753"
  location                = azurerm_resource_group.test.location
  resource_group_name     = azurerm_resource_group.test.name
  enable_ip_forwarding    = true
  internal_dns_name_label = "acctestni-0fr77"

  dns_servers = [
    "10.0.0.5",
    "10.0.0.7"
  ]

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.test.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    env = "Test2"
  }
}
