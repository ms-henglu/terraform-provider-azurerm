

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
  name     = "acctestRG-netapp-240311032721743078"
  location = "West Europe"

  tags = {
    "SkipNRMSNSG" = "true"
  }
}


resource "azurerm_user_assigned_identity" "test" {
  name                = "user-assigned-identity-240311032721743078"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

data "azurerm_client_config" "current" {
}

resource "azurerm_key_vault" "test" {
  name                            = "anfakv240311032721743078"
  location                        = azurerm_resource_group.test.location
  resource_group_name             = azurerm_resource_group.test.name
  enabled_for_disk_encryption     = true
  enabled_for_deployment          = true
  enabled_for_template_deployment = true
  purge_protection_enabled        = true
  tenant_id                       = "ARM_TENANT_ID"

  sku_name = "standard"

  access_policy {
    tenant_id = "ARM_TENANT_ID"
    object_id = data.azurerm_client_config.current.object_id

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

  access_policy {
    tenant_id = "ARM_TENANT_ID"
    object_id = azurerm_user_assigned_identity.test.principal_id

    key_permissions = [
      "Get",
      "Encrypt",
      "Decrypt"
    ]
  }
}

resource "azurerm_key_vault_key" "test" {
  name         = "anfenckey240311032721743078"
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

resource "azurerm_netapp_account" "test" {
  name                = "acctest-NetAppAccount-240311032721743078"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.test.id
    ]
  }
}

resource "azurerm_netapp_account_encryption" "test" {
  netapp_account_id = azurerm_netapp_account.test.id

  user_assigned_identity_id = azurerm_user_assigned_identity.test.id

  encryption_key = azurerm_key_vault_key.test.versionless_id
}
