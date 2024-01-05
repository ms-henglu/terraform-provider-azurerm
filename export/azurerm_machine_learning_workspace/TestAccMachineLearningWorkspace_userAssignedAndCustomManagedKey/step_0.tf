

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy       = false
      purge_soft_deleted_keys_on_destroy = false
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-ml-240105064115147809"
  location = "West Europe"
}

resource "azurerm_application_insights" "test" {
  name                = "acctestai-240105064115147809"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  application_type    = "web"
}

resource "azurerm_key_vault" "test" {
  name                = "acctestvaultsy3ml"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name = "standard"

  purge_protection_enabled = true
}

resource "azurerm_key_vault_access_policy" "test" {
  key_vault_id = azurerm_key_vault.test.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Create",
    "Get",
    "Delete",
    "Purge",
    "GetRotationPolicy",
  ]
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa240105064115109"
  location                 = azurerm_resource_group.test.location
  resource_group_name      = azurerm_resource_group.test.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}


data "azuread_service_principal" "test" {
  display_name = "Azure Cosmos DB"
}
resource "azurerm_key_vault_access_policy" "test-policy1" {
  key_vault_id = azurerm_key_vault.test.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azuread_service_principal.test.object_id

  key_permissions = [
    "Get",
    "Recover",
    "UnwrapKey",
    "WrapKey",
  ]
}

resource "azurerm_key_vault_key" "test" {
  name         = "accKVKey-240105064115147809"
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
  depends_on = [azurerm_key_vault.test, azurerm_key_vault_access_policy.test]
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestUAI-240105064115147809"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_key_vault_access_policy" "test-policy2" {
  key_vault_id = azurerm_key_vault.test.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.test.principal_id

  key_permissions = [
    "WrapKey",
    "UnwrapKey",
    "Get",
    "Recover",
  ]

  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete",
    "Recover",
    "Backup",
    "Restore"
  ]
}

resource "azurerm_role_assignment" "test_kv" {
  scope                = azurerm_key_vault.test.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.test.principal_id
}

resource "azurerm_role_assignment" "test_sa1" {
  scope                = azurerm_storage_account.test.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.test.principal_id
}

resource "azurerm_role_assignment" "test_sa2" {
  scope                = azurerm_storage_account.test.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.test.principal_id
}

resource "azurerm_role_assignment" "test_ai" {
  scope                = azurerm_application_insights.test.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.test.principal_id
}


resource "azurerm_machine_learning_workspace" "test" {
  name                           = "acctest-MLW-240105064115147809"
  location                       = azurerm_resource_group.test.location
  resource_group_name            = azurerm_resource_group.test.name
  application_insights_id        = azurerm_application_insights.test.id
  key_vault_id                   = azurerm_key_vault.test.id
  storage_account_id             = azurerm_storage_account.test.id
  primary_user_assigned_identity = azurerm_user_assigned_identity.test.id
  high_business_impact           = true

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.test.id,
    ]
  }

  encryption {
    user_assigned_identity_id = azurerm_user_assigned_identity.test.id
    key_vault_id              = azurerm_key_vault.test.id
    key_id                    = azurerm_key_vault_key.test.id
  }
  depends_on = [
    azurerm_role_assignment.test_ai, azurerm_role_assignment.test_kv, azurerm_role_assignment.test_sa1,
    azurerm_role_assignment.test_sa1,
    azurerm_key_vault_access_policy.test-policy1,
  ]
}
