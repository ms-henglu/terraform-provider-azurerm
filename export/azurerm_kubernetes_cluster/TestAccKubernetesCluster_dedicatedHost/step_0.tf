
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-230721014802875068"
  location = "West Europe"
}

resource "azurerm_dedicated_host_group" "test" {
  name                        = "acctestDHG-compute-230721014802875068"
  resource_group_name         = azurerm_resource_group.test.name
  location                    = azurerm_resource_group.test.location
  platform_fault_domain_count = 3
  automatic_placement_enabled = true
}

resource "azurerm_dedicated_host" "test" {
  name                    = "acctest-DH-230721014802875068"
  location                = azurerm_resource_group.test.location
  dedicated_host_group_id = azurerm_dedicated_host_group.test.id
  sku_name                = "FSv2-Type2"
  platform_fault_domain   = 0
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestWest Europe"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_role_assignment" "test" {
  scope                = azurerm_resource_group.test.id
  principal_id         = azurerm_user_assigned_identity.test.principal_id
  role_definition_name = "Contributor"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks230721014802875068"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks230721014802875068"

  default_node_pool {
    name          = "default"
    node_count    = 1
    vm_size       = "Standard_D2s_v3"
    host_group_id = azurerm_dedicated_host_group.test.id
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.test.id]
  }

  depends_on = [
    azurerm_role_assignment.test,
    azurerm_dedicated_host.test
  ]
}
  