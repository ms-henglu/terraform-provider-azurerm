
provider "azurerm" {
  features {}
}

provider "azuread" {
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-230915024139525055"
  location = "West Europe"
}

resource "azurerm_log_analytics_cluster" "test" {
  name                = "acctest-LA-230915024139525055"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  identity {
    type = "SystemAssigned"
  }
}

data "azuread_service_principal" "cosmos" {
  display_name = "Azure Cosmos DB"
}


resource "azurerm_key_vault" "test" {
  name                = "vaultuyirw"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name = "standard"

  soft_delete_retention_days = 7
  purge_protection_enabled   = true

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id
    key_permissions = [
      "Create",
      "Delete",
      "Get",
      "List",
      "Purge",
      "Update",
    ]

    secret_permissions = [
      "Get",
      "Delete",
      "Set",
    ]
  }

  access_policy {
    tenant_id = azurerm_log_analytics_cluster.test.identity.0.tenant_id
    object_id = azurerm_log_analytics_cluster.test.identity.0.principal_id
    key_permissions = [
      "Get",
      "UnwrapKey",
      "WrapKey"
    ]
  }

  access_policy {
    tenant_id = azurerm_log_analytics_cluster.test.identity.0.tenant_id
    object_id = data.azuread_service_principal.cosmos.object_id
    key_permissions = [
      "Get",
      "UnwrapKey",
      "WrapKey"
    ]
  }
}

resource "azurerm_key_vault_key" "test" {
  name         = "key-uyirw"
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

resource "azurerm_log_analytics_cluster_customer_managed_key" "test" {
  log_analytics_cluster_id = azurerm_log_analytics_cluster.test.id
  key_vault_key_id         = azurerm_key_vault_key.test.id

}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctest-law-230915024139525055"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  lifecycle {
    ignore_changes = [sku]
  }
}

resource "azurerm_log_analytics_linked_service" "test" {
  resource_group_name = azurerm_resource_group.test.name
  workspace_id        = azurerm_log_analytics_workspace.test.id
  write_access_id     = azurerm_log_analytics_cluster.test.id

  depends_on = [azurerm_log_analytics_cluster_customer_managed_key.test]
}

resource "azurerm_sentinel_log_analytics_workspace_onboarding" "test" {
  workspace_id                 = azurerm_log_analytics_workspace.test.id
  customer_managed_key_enabled = true

  depends_on = [azurerm_log_analytics_linked_service.test]
}
