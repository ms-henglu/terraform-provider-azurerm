

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-network-manager-230721012147161466"
  location = "West Europe"
}

data "azurerm_subscription" "current" {
}

resource "azurerm_network_manager" "test" {
  name                = "acctest-nm-230721012147161466"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  scope {
    subscription_ids = [data.azurerm_subscription.current.id]
  }
  scope_accesses = ["SecurityAdmin"]
}

resource "azurerm_network_manager_network_group" "test" {
  name               = "acctest-nmng-230721012147161466"
  network_manager_id = azurerm_network_manager.test.id
}

resource "azurerm_virtual_network" "test" {
  name                    = "acctest-vnet-230721012147161466"
  location                = azurerm_resource_group.test.location
  resource_group_name     = azurerm_resource_group.test.name
  address_space           = ["10.0.0.0/16"]
  flow_timeout_in_minutes = 10
}



resource "azurerm_network_manager_security_admin_configuration" "test" {
  name                                          = "acctest-nmsac-230721012147161466"
  network_manager_id                            = azurerm_network_manager.test.id
  description                                   = "update"
  apply_on_network_intent_policy_based_services = ["AllowRulesOnly"]
}
