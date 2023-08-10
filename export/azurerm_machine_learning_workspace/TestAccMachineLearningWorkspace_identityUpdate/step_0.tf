

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
  name     = "acctestRG-ml-230810143740643743"
  location = "West Europe"
}

resource "azurerm_application_insights" "test" {
  name                = "acctestai-230810143740643743"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  application_type    = "web"
}

resource "azurerm_key_vault" "test" {
  name                = "acctestvaultncxf8"
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
  name                     = "acctestsa230810143740643"
  location                 = azurerm_resource_group.test.location
  resource_group_name      = azurerm_resource_group.test.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}


resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestUAI-230810143740643743"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_role_assignment" "test" {
  scope                = azurerm_key_vault.test.id
  role_definition_name = "Key Vault Reader"
  principal_id         = azurerm_user_assigned_identity.test.principal_id
}

resource "azurerm_machine_learning_workspace" "test" {
  name                           = "acctest-MLW-230810143740643743"
  location                       = azurerm_resource_group.test.location
  resource_group_name            = azurerm_resource_group.test.name
  application_insights_id        = azurerm_application_insights.test.id
  key_vault_id                   = azurerm_key_vault.test.id
  storage_account_id             = azurerm_storage_account.test.id
  primary_user_assigned_identity = azurerm_user_assigned_identity.test.id

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.test.id,
    ]
  }

  depends_on = [azurerm_role_assignment.test]
}
