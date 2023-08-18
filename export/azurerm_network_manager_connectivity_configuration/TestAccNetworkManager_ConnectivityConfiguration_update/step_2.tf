

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-network-manager-230818024518146560"
  location = "West Europe"
}

data "azurerm_subscription" "current" {
}

resource "azurerm_network_manager" "test" {
  name                = "acctest-nm-230818024518146560"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  scope {
    subscription_ids = [data.azurerm_subscription.current.id]
  }
  scope_accesses = ["Connectivity"]
}

resource "azurerm_network_manager_network_group" "test" {
  name               = "acctest-nmng-230818024518146560"
  network_manager_id = azurerm_network_manager.test.id
}

resource "azurerm_virtual_network" "test" {
  name                    = "acctest-vnet-230818024518146560"
  location                = azurerm_resource_group.test.location
  resource_group_name     = azurerm_resource_group.test.name
  address_space           = ["10.0.0.0/16"]
  flow_timeout_in_minutes = 10
}


resource "azurerm_network_manager_connectivity_configuration" "test" {
  name                  = "acctest-nmcc-230818024518146560"
  network_manager_id    = azurerm_network_manager.test.id
  connectivity_topology = "HubAndSpoke"
  description           = "test"
  global_mesh_enabled   = true
  applies_to_group {
    group_connectivity = "DirectlyConnected"
    network_group_id   = azurerm_network_manager_network_group.test.id
  }
  hub {
    resource_id   = azurerm_virtual_network.test.id
    resource_type = "Microsoft.Network/virtualNetworks"
  }
}
