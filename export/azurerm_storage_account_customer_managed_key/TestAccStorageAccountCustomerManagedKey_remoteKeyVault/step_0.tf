
provider "azurerm" {
  features {}
}

provider "azurerm-alt" {
  subscription_id = ""
  tenant_id       = "ARM_TENANT_ID"
  features {
    key_vault {
      purge_soft_delete_on_destroy       = false
      purge_soft_deleted_keys_on_destroy = false
    }
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "remotetest" {
  provider = azurerm-alt

  name     = "acctestRG-alt-240105064703442504"
  location = "West Europe"
}

resource "azurerm_key_vault" "remotetest" {
  provider = azurerm-alt

  name                     = "acctestkvee0ty"
  location                 = azurerm_resource_group.remotetest.location
  resource_group_name      = azurerm_resource_group.remotetest.name
  tenant_id                = "ARM_TENANT_ID"
  sku_name                 = "standard"
  purge_protection_enabled = true
}

resource "azurerm_key_vault_access_policy" "storage" {
  provider = azurerm-alt

  key_vault_id = azurerm_key_vault.remotetest.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_storage_account.test.identity.0.principal_id

  key_permissions    = ["Get", "Create", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify"]
  secret_permissions = ["Get"]
}

resource "azurerm_key_vault_access_policy" "client" {
  provider = azurerm-alt

  key_vault_id = azurerm_key_vault.remotetest.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions    = ["Get", "Create", "Delete", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify", "GetRotationPolicy"]
  secret_permissions = ["Get"]
}

resource "azurerm_key_vault_key" "remote" {
  provider = azurerm-alt

  name         = "remote"
  key_vault_id = azurerm_key_vault.remotetest.id
  key_type     = "RSA"
  key_size     = 2048
  key_opts     = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]

  depends_on = [
    azurerm_key_vault_access_policy.client,
    azurerm_key_vault_access_policy.storage,
  ]
}

resource "azurerm_resource_group" "test" {
  provider = azurerm

  name     = "acctestRG-240105064703442504"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  provider = azurerm

  name                     = "acctestsaee0ty"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = ["customer_managed_key"]
  }
}

resource "azurerm_storage_account_customer_managed_key" "test" {
  provider = azurerm

  storage_account_id = azurerm_storage_account.test.id
  key_vault_id       = azurerm_key_vault.remotetest.id
  key_name           = azurerm_key_vault_key.remote.name
  key_version        = azurerm_key_vault_key.remote.version
}
