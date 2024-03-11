





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
  name     = "acctestRG-auto-240311031415468469"
  location = "West Europe"
}

resource "azurerm_key_vault" "test" {
  name                       = "vault240311031415468469"
  location                   = azurerm_resource_group.test.location
  resource_group_name        = azurerm_resource_group.test.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = true
  enable_rbac_authorization  = true
}

resource "azurerm_role_assignment" "current" {
  scope                = azurerm_key_vault.test.id
  principal_id         = data.azurerm_client_config.current.object_id
  role_definition_name = "Key Vault Crypto Officer"
}

data "azurerm_key_vault" "test" {
  name                = azurerm_key_vault.test.name
  resource_group_name = azurerm_key_vault.test.resource_group_name
}

resource "azurerm_key_vault_key" "test" {
  name         = "acckvkey-240311031415468469"
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

  depends_on = [azurerm_role_assignment.current]

}


resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestUAI-240311031415468469"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_role_assignment" "test2" {
  scope                = azurerm_key_vault_key.test.resource_versionless_id
  principal_id         = azurerm_user_assigned_identity.test.principal_id
  role_definition_name = "Key Vault Crypto Service Encryption User"
}

resource "azurerm_automation_account" "test" {
  name                = "acctest-240311031415468469"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Basic"

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.test.id
    ]
  }

  encryption {
    user_assigned_identity_id = azurerm_user_assigned_identity.test.id
    key_vault_key_id          = azurerm_key_vault_key.test.id
  }

  local_authentication_enabled = false
  depends_on                   = [azurerm_role_assignment.test2]
}
