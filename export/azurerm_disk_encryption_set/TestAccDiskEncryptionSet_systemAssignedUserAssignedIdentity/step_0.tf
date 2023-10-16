


provider "azurerm" {
  features {
    key_vault {
      recover_soft_deleted_key_vaults    = false
      purge_soft_delete_on_destroy       = false
      purge_soft_deleted_keys_on_destroy = false
    }
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016033603927169"
  location = "West Europe"
}

resource "azurerm_key_vault" "test" {
  name                        = "acctestkv-kjytb"
  location                    = azurerm_resource_group.test.location
  resource_group_name         = azurerm_resource_group.test.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  purge_protection_enabled    = true
  enabled_for_disk_encryption = true
}

resource "azurerm_key_vault_access_policy" "service-principal" {
  key_vault_id = azurerm_key_vault.test.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Create",
    "Delete",
    "Get",
    "Purge",
    "Update",
    "GetRotationPolicy",
  ]

  secret_permissions = [
    "Get",
    "Delete",
    "Purge",
    "Set",
  ]
}

resource "azurerm_key_vault_key" "test" {
  name         = "examplekey"
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

  depends_on = [azurerm_key_vault_access_policy.service-principal]
}



resource "azurerm_key_vault_access_policy" "disk-encryption" {
  key_vault_id = azurerm_key_vault.test.id

  key_permissions = [
    "Get",
    "WrapKey",
    "UnwrapKey",
    "GetRotationPolicy",
  ]

  tenant_id = azurerm_disk_encryption_set.test.identity.0.tenant_id
  object_id = azurerm_disk_encryption_set.test.identity.0.principal_id
}


resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestUAI-231016033603927169"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_key_vault_access_policy" "user-assigned" {
  key_vault_id = azurerm_key_vault.test.id
  tenant_id    = azurerm_user_assigned_identity.test.tenant_id
  object_id    = azurerm_user_assigned_identity.test.principal_id

  key_permissions = [
    "Get",
    "WrapKey",
    "UnwrapKey",
    "GetRotationPolicy",
  ]

  depends_on = [azurerm_key_vault_access_policy.service-principal]
}

resource "azurerm_disk_encryption_set" "test" {
  name                = "acctestDES-231016033603927169"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  key_vault_key_id    = azurerm_key_vault_key.test.id

  identity {
    type = "SystemAssigned, UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.test.id,
    ]
  }

  depends_on = [azurerm_key_vault_access_policy.user-assigned]
}
	