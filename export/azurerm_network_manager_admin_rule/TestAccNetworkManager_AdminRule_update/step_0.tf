
	
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-network-manager-230505050951299165"
  location = "West Europe"
}

data "azurerm_subscription" "current" {
}

resource "azurerm_network_manager" "test" {
  name                = "acctest-nm-230505050951299165"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  scope {
    subscription_ids = [data.azurerm_subscription.current.id]
  }
  scope_accesses = ["SecurityAdmin"]
}

resource "azurerm_network_manager_network_group" "test" {
  name               = "acctest-nmng-230505050951299165"
  network_manager_id = azurerm_network_manager.test.id
}

resource "azurerm_network_manager_security_admin_configuration" "test" {
  name               = "acctest-nmsac-230505050951299165"
  network_manager_id = azurerm_network_manager.test.id
}

resource "azurerm_network_manager_admin_rule_collection" "test" {
  name                            = "acctest-nmarc-230505050951299165"
  security_admin_configuration_id = azurerm_network_manager_security_admin_configuration.test.id
  network_group_ids               = [azurerm_network_manager_network_group.test.id]
}


resource "azurerm_network_manager_admin_rule" "test" {
  name                     = "acctest-nmar-230505050951299165"
  admin_rule_collection_id = azurerm_network_manager_admin_rule_collection.test.id
  action                   = "Deny"
  direction                = "Outbound"
  protocol                 = "Tcp"
  priority                 = 1
}
