
provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy       = true
      purge_soft_deleted_keys_on_destroy = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-recovery-240119025700984089"
  location = "West Europe"
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "test" {
  name                        = "acctest-key-vault-rc9mp"
  location                    = azurerm_resource_group.test.location
  resource_group_name         = azurerm_resource_group.test.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Create",
      "Decrypt",
      "Encrypt",
      "Delete",
      "Get",
      "List",
      "Purge",
      "UnwrapKey",
      "WrapKey",
      "Verify",
      "GetRotationPolicy"
    ]
    secret_permissions = [
      "Set",
    ]
  }
}

resource "azurerm_key_vault_key" "test" {
  name         = "acctest-key-vault-key"
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

resource "azurerm_recovery_services_vault" "test" {
  name                = "acctest-Vault-240119025700984089"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"

  encryption {
    key_id                            = azurerm_key_vault_key.test.id
    infrastructure_encryption_enabled = false
  }

  identity {
    type = "SystemAssigned"
  }
}
