
provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-db-230721011453348975"
  location = "eastus2"
}


resource "azurerm_key_vault" "test" {
  name                = "acctest-kv-fb336"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "premium"

  soft_delete_retention_days = 7
}

resource "azurerm_key_vault_key" "test" {
  depends_on = [azurerm_key_vault_access_policy.terraform]

  name         = "acctest-key-230721011453348975"
  key_vault_id = azurerm_key_vault.test.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
}

resource "azurerm_key_vault_access_policy" "terraform" {
  key_vault_id = azurerm_key_vault.test.id
  tenant_id    = azurerm_key_vault.test.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Get",
    "List",
    "Create",
    "Decrypt",
    "Encrypt",
    "GetRotationPolicy",
    "Sign",
    "UnwrapKey",
    "Verify",
    "WrapKey",
    "Delete",
    "Restore",
    "Recover",
    "Update",
    "Purge",
  ]
}

resource "azurerm_key_vault_access_policy" "databricks" {
  depends_on = [azurerm_databricks_workspace.test]

  key_vault_id = azurerm_key_vault.test.id
  tenant_id    = azurerm_databricks_workspace.test.storage_account_identity.0.tenant_id
  object_id    = azurerm_databricks_workspace.test.storage_account_identity.0.principal_id

  key_permissions = [
    "Get",
    "GetRotationPolicy",
    "UnwrapKey",
    "WrapKey",
    "Delete",
  ]
}


resource "azurerm_databricks_workspace" "test" {
  name                = "acctestDBW-230721011453348975"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "premium"

  customer_managed_key_enabled      = true
  infrastructure_encryption_enabled = true
}


resource "azurerm_databricks_workspace_customer_managed_key" "test" {
  depends_on = [azurerm_key_vault_access_policy.databricks]

  workspace_id     = azurerm_databricks_workspace.test.id
  key_vault_key_id = azurerm_key_vault_key.test.id
}

