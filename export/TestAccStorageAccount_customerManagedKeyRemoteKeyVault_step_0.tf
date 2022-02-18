
provider "azurerm" {
  features {}
}

provider "azurerm-alt" {
  subscription_id = ""
  tenant_id       = "ARM_TENANT_ID"
  features {
    key_vault {
      purge_soft_delete_on_destroy = false
    }
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "remotetest" {
  provider = azurerm-alt
  name     = "acctestRG-alt-220218071345847038"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  provider            = azurerm
  name                = "acctestmikve60"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_key_vault" "remotetest" {
  provider                 = azurerm-alt
  name                     = "acctestkvrkve60"
  location                 = azurerm_resource_group.remotetest.location
  resource_group_name      = azurerm_resource_group.remotetest.name
  tenant_id                = "ARM_TENANT_ID"
  sku_name                 = "standard"
  soft_delete_enabled      = true
  purge_protection_enabled = true
}

resource "azurerm_key_vault_access_policy" "storage" {
  provider           = azurerm-alt
  key_vault_id       = azurerm_key_vault.remotetest.id
  tenant_id          = data.azurerm_client_config.current.tenant_id
  object_id          = azurerm_user_assigned_identity.test.principal_id
  key_permissions    = ["get", "create", "list", "restore", "recover", "unwrapkey", "wrapkey", "purge", "encrypt", "decrypt", "sign", "verify"]
  secret_permissions = ["get"]
}

resource "azurerm_key_vault_access_policy" "client" {
  provider           = azurerm-alt
  key_vault_id       = azurerm_key_vault.remotetest.id
  tenant_id          = data.azurerm_client_config.current.tenant_id
  object_id          = data.azurerm_client_config.current.object_id
  key_permissions    = ["get", "create", "delete", "list", "restore", "recover", "unwrapkey", "wrapkey", "purge", "encrypt", "decrypt", "sign", "verify"]
  secret_permissions = ["get"]
}

resource "azurerm_key_vault_key" "remote" {
  provider     = azurerm-alt
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
  name     = "acctestRG-220218071345847038"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  provider                 = azurerm
  name                     = "acctestsakve60"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.test.id,
    ]
  }

  customer_managed_key {
    key_vault_key_id          = azurerm_key_vault_key.remote.id
    user_assigned_identity_id = azurerm_user_assigned_identity.test.id
  }
}
