

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }

    key_vault {
      purge_soft_delete_on_destroy       = false
      purge_soft_deleted_keys_on_destroy = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-netapp-240315123643823854"
  location = "West Europe"

  tags = {
    "SkipNRMSNSG" = "true"
  }
}


data "azurerm_client_config" "current" {
}

resource "azurerm_key_vault" "test" {
  name                            = "anfakv240315123643823854"
  location                        = azurerm_resource_group.test.location
  resource_group_name             = azurerm_resource_group.test.name
  enabled_for_disk_encryption     = true
  enabled_for_deployment          = true
  enabled_for_template_deployment = true
  purge_protection_enabled        = true
  tenant_id                       = "ARM_TENANT_ID"

  sku_name = "standard"
}

resource "azurerm_key_vault_access_policy" "test-currentuser" {
  key_vault_id = azurerm_key_vault.test.id
  tenant_id    = azurerm_netapp_account.test.identity.0.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Get",
    "Create",
    "Delete",
    "WrapKey",
    "UnwrapKey",
    "GetRotationPolicy",
    "SetRotationPolicy",
  ]
}

resource "azurerm_key_vault_key" "test" {
  name         = "anfenckey240315123643823854"
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

  depends_on = [
    azurerm_key_vault_access_policy.test-currentuser
  ]
}

resource "azurerm_key_vault_key" "test-new-key" {
  name         = "anfenckey-new240315123643823854"
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

  depends_on = [
    azurerm_key_vault_key.test,
    azurerm_key_vault_access_policy.test-currentuser
  ]
}

resource "azurerm_netapp_account" "test" {
  name                = "acctest-NetAppAccount-240315123643823854"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_key_vault_access_policy" "test-systemassigned" {
  key_vault_id = azurerm_key_vault.test.id
  tenant_id    = azurerm_netapp_account.test.identity.0.tenant_id
  object_id    = azurerm_netapp_account.test.identity.0.principal_id

  key_permissions = [
    "Get",
    "Encrypt",
    "Decrypt"
  ]
}

resource "azurerm_netapp_account_encryption" "test" {
  netapp_account_id = azurerm_netapp_account.test.id

  system_assigned_identity_principal_id = azurerm_netapp_account.test.identity.0.principal_id

  encryption_key = azurerm_key_vault_key.test.versionless_id

  depends_on = [
    azurerm_key_vault_access_policy.test-systemassigned
  ]
}
