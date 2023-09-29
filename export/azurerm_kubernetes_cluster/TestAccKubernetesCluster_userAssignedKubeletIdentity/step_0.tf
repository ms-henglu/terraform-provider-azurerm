
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-230929064631529146"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "aks_identity_test" {
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  name                = "test_identity"
}

resource "azurerm_user_assigned_identity" "kubelet_identity_test" {
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  name                = "test_kubelet_identity"
}

resource "azurerm_role_assignment" "manage_kubelet_identity" {
  scope                            = azurerm_resource_group.test.id
  role_definition_name             = "Managed Identity Operator"
  principal_id                     = azurerm_user_assigned_identity.aks_identity_test.principal_id
  skip_service_principal_aad_check = false
}

resource "azurerm_kubernetes_cluster" "test" {
  depends_on          = [azurerm_role_assignment.manage_kubelet_identity]
  name                = "acctestaks230929064631529146"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks230929064631529146"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks_identity_test.id]
  }

  kubelet_identity {
    user_assigned_identity_id = azurerm_user_assigned_identity.kubelet_identity_test.id
    client_id                 = azurerm_user_assigned_identity.kubelet_identity_test.client_id
    object_id                 = azurerm_user_assigned_identity.kubelet_identity_test.principal_id
  }
}
