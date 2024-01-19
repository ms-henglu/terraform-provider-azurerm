

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy       = false
      purge_soft_deleted_keys_on_destroy = false
    }
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025452511601"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestminck9z"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_key_vault" "test" {
  name                     = "acctestkvnck9z"
  location                 = azurerm_resource_group.test.location
  resource_group_name      = azurerm_resource_group.test.name
  tenant_id                = data.azurerm_client_config.current.tenant_id
  sku_name                 = "standard"
  purge_protection_enabled = true
}

resource "azurerm_key_vault_access_policy" "server" {
  key_vault_id = azurerm_key_vault.test.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.test.principal_id

  key_permissions = ["Get", "List", "WrapKey", "UnwrapKey", "GetRotationPolicy", "SetRotationPolicy"]
}

resource "azurerm_key_vault_access_policy" "client" {
  key_vault_id = azurerm_key_vault.test.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = ["Get", "Create", "Delete", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify", "GetRotationPolicy", "SetRotationPolicy"]
}

resource "azurerm_key_vault_key" "test" {
  name         = "test"
  key_vault_id = azurerm_key_vault.test.id
  key_type     = "RSA"
  key_size     = 2048
  key_opts     = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]

  depends_on = [
    azurerm_key_vault_access_policy.client,
    azurerm_key_vault_access_policy.server,
  ]
}


resource "azurerm_resource_group" "test2" {
  name     = "acctestRG-mysql2-240119025452511601"
  location = "West US 2"
}

resource "azurerm_user_assigned_identity" "test2" {
  name                = "acctestminck9z"
  location            = azurerm_resource_group.test2.location
  resource_group_name = azurerm_resource_group.test2.name
}

resource "azurerm_key_vault" "test2" {
  name                     = "acctestkv2nck9z"
  location                 = azurerm_resource_group.test2.location
  resource_group_name      = azurerm_resource_group.test2.name
  tenant_id                = data.azurerm_client_config.current.tenant_id
  sku_name                 = "standard"
  purge_protection_enabled = true
}

resource "azurerm_key_vault_access_policy" "server2" {
  key_vault_id = azurerm_key_vault.test2.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.test2.principal_id

  key_permissions = ["Get", "List", "WrapKey", "UnwrapKey"]
}

resource "azurerm_key_vault_access_policy" "client2" {
  key_vault_id = azurerm_key_vault.test2.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = ["Get", "Create", "Delete", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify", "GetRotationPolicy"]
}

resource "azurerm_key_vault_key" "test2" {
  name         = "test2"
  key_vault_id = azurerm_key_vault.test2.id
  key_type     = "RSA"
  key_size     = 2048
  key_opts     = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]

  depends_on = [
    azurerm_key_vault_access_policy.client2,
    azurerm_key_vault_access_policy.server2,
  ]
}

resource "azurerm_mysql_flexible_server" "test" {
  name                         = "acctest-fs-240119025452511601"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  administrator_login          = "_admin_Terraform_892123456789312"
  administrator_password       = "QAZwsx123"
  sku_name                     = "B_Standard_B1s"
  zone                         = "2"
  geo_redundant_backup_enabled = true

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.test.id, azurerm_user_assigned_identity.test2.id]
  }

  customer_managed_key {
    key_vault_key_id                     = azurerm_key_vault_key.test.id
    primary_user_assigned_identity_id    = azurerm_user_assigned_identity.test.id
    geo_backup_key_vault_key_id          = azurerm_key_vault_key.test2.id
    geo_backup_user_assigned_identity_id = azurerm_user_assigned_identity.test2.id
  }
}
