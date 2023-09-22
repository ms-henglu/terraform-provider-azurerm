

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922061636793400"
  location = "West Europe"
}

resource "azurerm_network_security_group" "test" {
  name                = "acceptanceTestSecurityGroup1"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_network_security_rule" "test" {
  name                        = "test123"
  network_security_group_name = azurerm_network_security_group.test.name
  resource_group_name         = azurerm_resource_group.test.name
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}


resource "azurerm_network_security_rule" "import" {
  name                        = azurerm_network_security_rule.test.name
  network_security_group_name = azurerm_network_security_rule.test.network_security_group_name
  resource_group_name         = azurerm_network_security_rule.test.resource_group_name
  priority                    = azurerm_network_security_rule.test.priority
  direction                   = azurerm_network_security_rule.test.direction
  access                      = azurerm_network_security_rule.test.access
  protocol                    = azurerm_network_security_rule.test.protocol
  source_port_range           = azurerm_network_security_rule.test.source_port_range
  destination_port_range      = azurerm_network_security_rule.test.destination_port_range
  source_address_prefix       = azurerm_network_security_rule.test.source_address_prefix
  destination_address_prefix  = azurerm_network_security_rule.test.destination_address_prefix
}
