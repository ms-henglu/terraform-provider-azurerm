

	
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-network-manager-230929065414949500"
  location = "West Europe"
}

data "azurerm_subscription" "current" {
}

resource "azurerm_network_manager" "test" {
  name                = "acctest-nm-230929065414949500"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  scope {
    subscription_ids = [data.azurerm_subscription.current.id]
  }
  scope_accesses = ["SecurityAdmin"]
}

resource "azurerm_network_manager_network_group" "test" {
  name               = "acctest-nmng-230929065414949500"
  network_manager_id = azurerm_network_manager.test.id
}

resource "azurerm_network_manager_security_admin_configuration" "test" {
  name               = "acctest-nmsac-230929065414949500"
  network_manager_id = azurerm_network_manager.test.id
}

resource "azurerm_network_manager_admin_rule_collection" "test" {
  name                            = "acctest-nmarc-230929065414949500"
  security_admin_configuration_id = azurerm_network_manager_security_admin_configuration.test.id
  network_group_ids               = [azurerm_network_manager_network_group.test.id]
}


resource "azurerm_network_manager_admin_rule" "test" {
  name                     = "acctest-nmar-230929065414949500"
  admin_rule_collection_id = azurerm_network_manager_admin_rule_collection.test.id
  action                   = "Deny"
  direction                = "Outbound"
  protocol                 = "Tcp"
  priority                 = 1
}


resource "azurerm_network_manager_admin_rule" "import" {
  name                     = azurerm_network_manager_admin_rule.test.name
  admin_rule_collection_id = azurerm_network_manager_admin_rule.test.admin_rule_collection_id
  action                   = azurerm_network_manager_admin_rule.test.action
  direction                = azurerm_network_manager_admin_rule.test.direction
  priority                 = azurerm_network_manager_admin_rule.test.priority
  protocol                 = azurerm_network_manager_admin_rule.test.protocol
}
