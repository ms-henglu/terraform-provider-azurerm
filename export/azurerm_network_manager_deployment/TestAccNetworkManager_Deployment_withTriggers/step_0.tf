

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-network-manager-230825025021992359"
  location = "West Europe"
}

data "azurerm_subscription" "current" {
}

resource "azurerm_network_manager" "test" {
  name                = "acctest-nm-230825025021992359"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  scope {
    subscription_ids = [data.azurerm_subscription.current.id]
  }
  scope_accesses = ["SecurityAdmin", "Connectivity"]
}

resource "azurerm_network_manager_network_group" "test" {
  name               = "acctest-nmng-230825025021992359"
  network_manager_id = azurerm_network_manager.test.id
}

resource "azurerm_virtual_network" "test" {
  name                    = "acctest-vnet-230825025021992359"
  location                = azurerm_resource_group.test.location
  resource_group_name     = azurerm_resource_group.test.name
  address_space           = ["10.0.0.0/16"]
  flow_timeout_in_minutes = 10
}

resource "azurerm_network_manager_connectivity_configuration" "test" {
  name                  = "acctest-nmcc-230825025021992359"
  network_manager_id    = azurerm_network_manager.test.id
  connectivity_topology = "HubAndSpoke"
  applies_to_group {
    group_connectivity = "None"
    network_group_id   = azurerm_network_manager_network_group.test.id
  }
  hub {
    resource_id   = azurerm_virtual_network.test.id
    resource_type = "Microsoft.Network/virtualNetworks"
  }
}


resource "azurerm_network_manager_security_admin_configuration" "test" {
  name               = "acctest-nmsac-230825025021992359"
  network_manager_id = azurerm_network_manager.test.id
}

resource "azurerm_network_manager_admin_rule_collection" "test" {
  name                            = "acctest-nmarc-230825025021992359"
  security_admin_configuration_id = azurerm_network_manager_security_admin_configuration.test.id
  network_group_ids               = [azurerm_network_manager_network_group.test.id]
}

resource "azurerm_network_manager_admin_rule" "test" {
  name                     = "acctest-nmar-230825025021992359"
  admin_rule_collection_id = azurerm_network_manager_admin_rule_collection.test.id
  action                   = "Deny"
  description              = "test"
  direction                = "Inbound"
  priority                 = 1
  protocol                 = "Tcp"
  source_port_ranges       = ["80"]
  destination_port_ranges  = ["80"]
  source {
    address_prefix_type = "ServiceTag"
    address_prefix      = "Internet"
  }
  destination {
    address_prefix_type = "IPPrefix"
    address_prefix      = "*"
  }
}

resource "azurerm_network_manager_deployment" "test" {
  network_manager_id = azurerm_network_manager.test.id
  location           = "eastus"
  scope_access       = "SecurityAdmin"
  configuration_ids  = [azurerm_network_manager_security_admin_configuration.test.id]
  depends_on         = [azurerm_network_manager_admin_rule.test]
  triggers = {
    source_port_ranges = join(",", azurerm_network_manager_admin_rule.test.source_port_ranges)
  }
}

