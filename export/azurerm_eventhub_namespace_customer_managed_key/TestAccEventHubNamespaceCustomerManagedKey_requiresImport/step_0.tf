

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy       = false
      purge_soft_deleted_keys_on_destroy = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-namespacecmk-240119025039074633"
  location = "West Europe"
}

resource "azurerm_eventhub_cluster" "test" {
  name                = "acctest-cluster-240119025039074633"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku_name            = "Dedicated_1"
}

resource "azurerm_eventhub_namespace" "test" {
  name                 = "acctest-namespace-240119025039074633"
  location             = azurerm_resource_group.test.location
  resource_group_name  = azurerm_resource_group.test.name
  sku                  = "Standard"
  dedicated_cluster_id = azurerm_eventhub_cluster.test.id

  identity {
    type = "SystemAssigned"
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "test" {
  name                     = "acctestkvdo2g0"
  location                 = azurerm_resource_group.test.location
  resource_group_name      = azurerm_resource_group.test.name
  tenant_id                = data.azurerm_client_config.current.tenant_id
  sku_name                 = "standard"
  purge_protection_enabled = true
}

resource "azurerm_key_vault_access_policy" "test" {
  key_vault_id = azurerm_key_vault.test.id
  tenant_id    = azurerm_eventhub_namespace.test.identity.0.tenant_id
  object_id    = azurerm_eventhub_namespace.test.identity.0.principal_id

  key_permissions = ["Get", "UnwrapKey", "WrapKey", "GetRotationPolicy"]
}

resource "azurerm_key_vault_access_policy" "test2" {
  key_vault_id = azurerm_key_vault.test.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Create",
    "Delete",
    "Get",
    "List",
    "Purge",
    "Recover",
    "GetRotationPolicy"
  ]
}

resource "azurerm_key_vault_key" "test" {
  name         = "acctestkvkeydo2g0"
  key_vault_id = azurerm_key_vault.test.id
  key_type     = "RSA"
  key_size     = 2048
  key_opts     = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]

  depends_on = [
    azurerm_key_vault_access_policy.test,
    azurerm_key_vault_access_policy.test2,
  ]
}


resource "azurerm_eventhub_namespace_customer_managed_key" "test" {
  eventhub_namespace_id = azurerm_eventhub_namespace.test.id
  key_vault_key_ids     = [azurerm_key_vault_key.test.id]
}
