


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-network-manager-240105061256834470"
  location = "West Europe"
}

data "azurerm_client_config" "current" {
}

data "azurerm_subscription" "current" {
}

resource "azurerm_network_manager" "test" {
  name                = "acctest-networkmanager-240105061256834470"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  scope {
    subscription_ids = [data.azurerm_subscription.current.id]
  }
  scope_accesses = ["SecurityAdmin"]
}


resource "azurerm_network_manager_scope_connection" "test" {
  name               = "acctest-nsc-240105061256834470"
  network_manager_id = azurerm_network_manager.test.id
  tenant_id          = data.azurerm_client_config.current.tenant_id
  target_scope_id    = data.azurerm_subscription.current.id
}


resource "azurerm_network_manager_scope_connection" "import" {
  name               = azurerm_network_manager_scope_connection.test.name
  network_manager_id = azurerm_network_manager_scope_connection.test.network_manager_id
  tenant_id          = azurerm_network_manager_scope_connection.test.tenant_id
  target_scope_id    = azurerm_network_manager_scope_connection.test.target_scope_id
}
