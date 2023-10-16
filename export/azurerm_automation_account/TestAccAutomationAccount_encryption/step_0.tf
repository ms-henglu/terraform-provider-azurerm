
provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy       = false
      purge_soft_deleted_keys_on_destroy = false
    }
  }
}

data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-auto-231016033425287178"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestUAI-231016033425287178"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_key_vault" "test" {
  name                       = "vault231016033425287178"
  location                   = azurerm_resource_group.test.location
  resource_group_name        = azurerm_resource_group.test.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = true

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    certificate_permissions = [
      "ManageContacts",
    ]

    key_permissions = [
      "Create",
      "Get",
      "List",
      "Delete",
      "Purge",
      "GetRotationPolicy",
    ]

    secret_permissions = [
      "Set",
    ]
  }

  access_policy {
    tenant_id = azurerm_user_assigned_identity.test.tenant_id
    object_id = azurerm_user_assigned_identity.test.principal_id

    certificate_permissions = []

    key_permissions = [
      "Get",
      "Recover",
      "WrapKey",
      "UnwrapKey",
      "GetRotationPolicy",
    ]

    secret_permissions = []
  }
}

data "azurerm_key_vault" "test" {
  name                = azurerm_key_vault.test.name
  resource_group_name = azurerm_key_vault.test.resource_group_name
}

resource "azurerm_key_vault_key" "test" {
  name         = "acckvkey-231016033425287178"
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

resource "azurerm_automation_account" "test" {
  name                = "acctest-231016033425287178"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Basic"

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.test.id
    ]
  }

  local_authentication_enabled = false

  encryption {
    user_assigned_identity_id = azurerm_user_assigned_identity.test.id
    key_vault_key_id          = azurerm_key_vault_key.test.id
  }
}
