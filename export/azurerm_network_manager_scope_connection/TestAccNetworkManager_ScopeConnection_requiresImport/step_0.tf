

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-network-manager-231218072256361327"
  location = "West Europe"
}

data "azurerm_client_config" "current" {
}

data "azurerm_subscription" "current" {
}

resource "azurerm_network_manager" "test" {
  name                = "acctest-networkmanager-231218072256361327"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  scope {
    subscription_ids = [data.azurerm_subscription.current.id]
  }
  scope_accesses = ["SecurityAdmin"]
}


resource "azurerm_network_manager_scope_connection" "test" {
  name               = "acctest-nsc-231218072256361327"
  network_manager_id = azurerm_network_manager.test.id
  tenant_id          = data.azurerm_client_config.current.tenant_id
  target_scope_id    = data.azurerm_subscription.current.id
}
