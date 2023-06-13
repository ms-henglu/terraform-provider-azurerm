

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-network-manager-230613072348629627"
  location = "West Europe"
}

data "azurerm_subscription" "current" {
}

resource "azurerm_network_manager" "test" {
  name                = "acctest-nm-230613072348629627"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  scope {
    subscription_ids = [data.azurerm_subscription.current.id]
  }
  scope_accesses = ["SecurityAdmin"]
}

resource "azurerm_network_manager_network_group" "test" {
  name               = "acctest-nmng-230613072348629627"
  network_manager_id = azurerm_network_manager.test.id
}

resource "azurerm_network_manager_security_admin_configuration" "test" {
  name               = "acctest-nmsac-230613072348629627"
  network_manager_id = azurerm_network_manager.test.id
}


resource "azurerm_network_manager_network_group" "test2" {
  name               = "acctest-nmng2-230613072348629627"
  network_manager_id = azurerm_network_manager.test.id
}

resource "azurerm_network_manager_admin_rule_collection" "test" {
  name                            = "acctest-nmarc-230613072348629627"
  security_admin_configuration_id = azurerm_network_manager_security_admin_configuration.test.id
  description                     = "test admin rule collection"
  network_group_ids               = [azurerm_network_manager_network_group.test.id, azurerm_network_manager_network_group.test2.id]
}
