


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-network-manager-231218072256377587"
  location = "West Europe"
}

data "azurerm_subscription" "current" {
}

resource "azurerm_network_manager" "test" {
  name                = "acctest-nm-231218072256377587"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  scope {
    subscription_ids = [data.azurerm_subscription.current.id]
  }
  scope_accesses = ["Connectivity"]
}

resource "azurerm_network_manager_network_group" "test" {
  name               = "acctest-nmng-231218072256377587"
  network_manager_id = azurerm_network_manager.test.id
}

resource "azurerm_virtual_network" "test" {
  name                    = "acctest-vnet-231218072256377587"
  location                = azurerm_resource_group.test.location
  resource_group_name     = azurerm_resource_group.test.name
  address_space           = ["10.0.0.0/16"]
  flow_timeout_in_minutes = 10
}


resource "azurerm_network_manager_connectivity_configuration" "test" {
  name                  = "acctest-nmcc-231218072256377587"
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


resource "azurerm_network_manager_connectivity_configuration" "import" {
  name                  = azurerm_network_manager_connectivity_configuration.test.name
  network_manager_id    = azurerm_network_manager_connectivity_configuration.test.network_manager_id
  connectivity_topology = azurerm_network_manager_connectivity_configuration.test.connectivity_topology
  applies_to_group {
    group_connectivity = azurerm_network_manager_connectivity_configuration.test.applies_to_group.0.group_connectivity
    network_group_id   = azurerm_network_manager_connectivity_configuration.test.applies_to_group.0.network_group_id
  }
  hub {
    resource_id   = azurerm_network_manager_connectivity_configuration.test.hub.0.resource_id
    resource_type = azurerm_network_manager_connectivity_configuration.test.hub.0.resource_type
  }
}
