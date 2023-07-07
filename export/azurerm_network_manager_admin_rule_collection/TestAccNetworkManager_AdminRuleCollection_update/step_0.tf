
	
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-network-manager-230707010742381414"
  location = "West Europe"
}

data "azurerm_subscription" "current" {
}

resource "azurerm_network_manager" "test" {
  name                = "acctest-nm-230707010742381414"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  scope {
    subscription_ids = [data.azurerm_subscription.current.id]
  }
  scope_accesses = ["SecurityAdmin"]
}

resource "azurerm_network_manager_network_group" "test" {
  name               = "acctest-nmng-230707010742381414"
  network_manager_id = azurerm_network_manager.test.id
}

resource "azurerm_network_manager_security_admin_configuration" "test" {
  name               = "acctest-nmsac-230707010742381414"
  network_manager_id = azurerm_network_manager.test.id
}


resource "azurerm_network_manager_admin_rule_collection" "test" {
  name                            = "acctest-nmarc-230707010742381414"
  security_admin_configuration_id = azurerm_network_manager_security_admin_configuration.test.id
  network_group_ids               = [azurerm_network_manager_network_group.test.id]
}
