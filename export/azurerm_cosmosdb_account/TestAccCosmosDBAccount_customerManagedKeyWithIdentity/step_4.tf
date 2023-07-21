
provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy       = false
      purge_soft_deleted_keys_on_destroy = false
    }
  }
}

provider "azuread" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cosmos-230721014812076679"
  location = "West Europe"
}

data "azurerm_client_config" "current" {}

data "azuread_service_principal" "cosmosdb" {
  display_name = "Azure Cosmos DB"
}

resource "azurerm_user_assigned_identity" "test" {
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  name                = "acctest-user-example"
}

resource "azurerm_key_vault" "test" {
  name                = "acctestkv-3hhgq"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  purge_protection_enabled   = true
  soft_delete_retention_days = 7

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "List",
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
      "Set",
    ]
  }

  access_policy {
    tenant_id = azurerm_user_assigned_identity.test.tenant_id
    object_id = azurerm_user_assigned_identity.test.principal_id

    key_permissions = [
      "List",
      "Create",
      "Delete",
      "Get",
      "Update",
      "UnwrapKey",
      "WrapKey",
      "GetRotationPolicy",
    ]

    secret_permissions = [
      "Get",
      "Delete",
      "Set",
    ]
  }

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azuread_service_principal.cosmosdb.id

    key_permissions = [
      "List",
      "Create",
      "Delete",
      "Get",
      "Update",
      "UnwrapKey",
      "WrapKey",
      "GetRotationPolicy",
    ]

    secret_permissions = [
      "Get",
      "Delete",
      "Set",
    ]
  }
}

resource "azurerm_key_vault_key" "test" {
  name         = "key-3hhgq"
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

resource "azurerm_cosmosdb_account" "test" {
  name                = "acctest-ca-230721014812076679"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  offer_type          = "Standard"
  kind                = "MongoDB"
  key_vault_key_id    = azurerm_key_vault_key.test.versionless_id

  capabilities {
    name = "EnableMongo"
  }

  consistency_policy {
    consistency_level = "Strong"
  }

  geo_location {
    location          = azurerm_resource_group.test.location
    failover_priority = 0
  }

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.test.id
    ]
  }
}
