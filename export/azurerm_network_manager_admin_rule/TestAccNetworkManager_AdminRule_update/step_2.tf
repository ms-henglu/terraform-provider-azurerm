

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-network-manager-231020041557294781"
  location = "West Europe"
}

data "azurerm_subscription" "current" {
}

resource "azurerm_network_manager" "test" {
  name                = "acctest-nm-231020041557294781"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  scope {
    subscription_ids = [data.azurerm_subscription.current.id]
  }
  scope_accesses = ["SecurityAdmin"]
}

resource "azurerm_network_manager_network_group" "test" {
  name               = "acctest-nmng-231020041557294781"
  network_manager_id = azurerm_network_manager.test.id
}

resource "azurerm_network_manager_security_admin_configuration" "test" {
  name               = "acctest-nmsac-231020041557294781"
  network_manager_id = azurerm_network_manager.test.id
}

resource "azurerm_network_manager_admin_rule_collection" "test" {
  name                            = "acctest-nmarc-231020041557294781"
  security_admin_configuration_id = azurerm_network_manager_security_admin_configuration.test.id
  network_group_ids               = [azurerm_network_manager_network_group.test.id]
}


resource "azurerm_network_manager_admin_rule" "test" {
  name                     = "acctest-nmar-231020041557294781"
  admin_rule_collection_id = azurerm_network_manager_admin_rule_collection.test.id
  action                   = "Allow"
  description              = "test"
  direction                = "Inbound"
  priority                 = 1234
  protocol                 = "Ah"
  source_port_ranges       = ["80", "1024-65535"]
  destination_port_ranges  = ["80"]
  source {
    address_prefix_type = "ServiceTag"
    address_prefix      = "ActionGroup"
  }
  destination {
    address_prefix_type = "IPPrefix"
    address_prefix      = "10.1.0.1"
  }
  destination {
    address_prefix_type = "IPPrefix"
    address_prefix      = "10.0.0.0/24"
  }
}
