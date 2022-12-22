

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy       = false
      purge_soft_deleted_keys_on_destroy = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-synapse-221222035438269428"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccv4q6r"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_kind             = "BlobStorage"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_data_lake_gen2_filesystem" "test" {
  name               = "acctest-221222035438269428"
  storage_account_id = azurerm_storage_account.test.id
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "test" {
  name                     = "acckv221222035438269428"
  location                 = azurerm_resource_group.test.location
  resource_group_name      = azurerm_resource_group.test.name
  tenant_id                = data.azurerm_client_config.current.tenant_id
  sku_name                 = "standard"
  purge_protection_enabled = true
}

resource "azurerm_key_vault_access_policy" "deployer" {
  key_vault_id = azurerm_key_vault.test.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Create", "Get", "Delete", "Purge"
  ]
}

resource "azurerm_key_vault_key" "test" {
  name         = "key"
  key_vault_id = azurerm_key_vault.test.id
  key_type     = "RSA"
  key_size     = 2048
  key_opts = [
    "unwrapKey",
    "wrapKey"
  ]
  depends_on = [
    azurerm_key_vault_access_policy.deployer
  ]
}

resource "azurerm_key_vault_key" "test2" {
  name         = "key2"
  key_vault_id = azurerm_key_vault.test.id
  key_type     = "RSA"
  key_size     = 2048
  key_opts = [
    "unwrapKey",
    "wrapKey"
  ]
  depends_on = [
    azurerm_key_vault_access_policy.deployer
  ]
}



resource "azurerm_synapse_workspace" "test" {
  name                                 = "acctestsw221222035438269428"
  resource_group_name                  = azurerm_resource_group.test.name
  location                             = azurerm_resource_group.test.location
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.test.id
  sql_administrator_login              = "sqladminuser"
  sql_administrator_login_password     = "H@Sh1CoR3!"
  customer_managed_key {
    key_versionless_id = azurerm_key_vault_key.test.versionless_id
    key_name           = "test_key"
  }
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_key_vault_access_policy" "workspace_policy" {
  key_vault_id = azurerm_key_vault.test.id
  tenant_id    = azurerm_synapse_workspace.test.identity[0].tenant_id
  object_id    = azurerm_synapse_workspace.test.identity[0].principal_id

  key_permissions = [
    "Get", "WrapKey", "UnwrapKey"
  ]
}

resource "azurerm_synapse_workspace_key" "test" {
  customer_managed_key_versionless_id = azurerm_key_vault_key.test.versionless_id
  synapse_workspace_id                = azurerm_synapse_workspace.test.id
  active                              = true
  customer_managed_key_name           = "test_key"
  depends_on                          = [azurerm_key_vault_access_policy.workspace_policy]
}

resource "azurerm_synapse_workspace_key" "test2" {
  customer_managed_key_versionless_id = azurerm_key_vault_key.test2.versionless_id
  synapse_workspace_id                = azurerm_synapse_workspace.test.id
  active                              = false
  customer_managed_key_name           = "test_key2"
  depends_on                          = [azurerm_key_vault_access_policy.workspace_policy, azurerm_synapse_workspace_key.test]
}
