
provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-231013043207727126"
  location = "West Europe"
}

resource "azurerm_key_vault" "test" {
  name                      = substr("acctest231013043207727126", 0, 24)
  location                  = azurerm_resource_group.test.location
  resource_group_name       = azurerm_resource_group.test.name
  tenant_id                 = data.azurerm_client_config.current.tenant_id
  enable_rbac_authorization = true
  sku_name                  = "standard"
}

resource "azurerm_role_assignment" "test_admin" {
  scope                = azurerm_key_vault.test.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "test" {
  scope                = azurerm_key_vault.test.id
  role_definition_name = "Key Vault Crypto User"
  principal_id         = azurerm_user_assigned_identity.test.principal_id
}

resource "azurerm_key_vault_key" "test" {
  name         = "etcd-encryption"
  key_vault_id = azurerm_key_vault.test.id
  key_type     = "RSA"
  key_size     = 2048
  key_opts     = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]

  depends_on = [azurerm_role_assignment.test_admin]
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctest231013043207727126"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks231013043207727126"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  node_resource_group = "${azurerm_resource_group.test.name}-infra"
  dns_prefix          = "acctestaks231013043207727126"
  kubernetes_version  = "1.26.6"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.test.id]
  }
  
  key_management_service {
    key_vault_key_id = azurerm_key_vault_key.test.id
  }
}
