
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240315123704057547"
  location = "West Europe"
}

resource "azurerm_network_security_group" "test" {
  name                = "acceptanceTestSecurityGroup1"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  security_rule {
    name                         = "test123"
    priority                     = 100
    direction                    = "Inbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_ranges           = ["10000-40000"]
    destination_port_ranges      = ["80", "443", "8080", "8190"]
    source_address_prefixes      = ["10.0.0.0/8", "192.168.0.0/16"]
    destination_address_prefixes = ["172.16.0.0/20", "8.8.8.8"]
  }
}
