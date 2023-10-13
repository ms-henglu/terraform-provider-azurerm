
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test1" {
  name     = "acctestRG-231013043954310734"
  location = "West Europe"
}

resource "azurerm_network_security_group" "test1" {
  name                = "acceptanceTestSecurityGroup2"
  location            = azurerm_resource_group.test1.location
  resource_group_name = azurerm_resource_group.test1.name
}

resource "azurerm_network_security_rule" "test1" {
  name                         = "test123"
  priority                     = 100
  direction                    = "Outbound"
  access                       = "Allow"
  protocol                     = "Tcp"
  source_port_ranges           = ["10000-40000"]
  destination_port_ranges      = ["80", "443", "8080", "8190"]
  source_address_prefixes      = ["10.0.0.0/8", "192.168.0.0/16"]
  destination_address_prefixes = ["172.16.0.0/20", "8.8.8.8"]
  resource_group_name          = azurerm_resource_group.test1.name
  network_security_group_name  = azurerm_network_security_group.test1.name
}
