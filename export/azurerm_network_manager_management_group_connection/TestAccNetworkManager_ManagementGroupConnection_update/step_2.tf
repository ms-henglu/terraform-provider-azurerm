

provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
}

resource "azurerm_management_group_subscription_association" "test" {
  management_group_id = azurerm_management_group.test.id
  subscription_id     = data.azurerm_subscription.alt.id
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-network-manager-240315123704044712"
  location = "West Europe"
}

data "azurerm_subscription" "alt" {
  subscription_id = ""
}

data "azurerm_subscription" "current" {
}

data "azurerm_client_config" "current" {
}

resource "azurerm_role_assignment" "network_contributor" {
  scope                = azurerm_management_group.test.id
  role_definition_name = "Network Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_network_manager" "test" {
  name                = "acctest-networkmanager-240315123704044712"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  scope {
    subscription_ids = [data.azurerm_subscription.current.id]
  }
  scope_accesses = ["SecurityAdmin"]
  depends_on     = [azurerm_role_assignment.network_contributor]
}


resource "azurerm_network_manager_management_group_connection" "test" {
  name                = "acctest-nmmgc-240315123704044712"
  management_group_id = azurerm_management_group.test.id
  network_manager_id  = azurerm_network_manager.test.id
  description         = "update"
}
