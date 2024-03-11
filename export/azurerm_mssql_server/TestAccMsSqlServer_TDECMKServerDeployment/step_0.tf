
provider "azurerm" {
  features {}
}

data "azurerm_client_config" "test" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mssql-240311032631178793"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  name                = "test_identity_2112"
}

resource "azurerm_mssql_server" "test" {
  name                         = "acctestsqlserver240311032631178793"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "DaveLister"
  administrator_login_password = "7h1515K4711"
  minimum_tls_version          = "1.2"

  azuread_administrator {
    login_username = azurerm_user_assigned_identity.test.name
    object_id      = azurerm_user_assigned_identity.test.principal_id
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.test.id]
  }

  primary_user_assigned_identity_id            = azurerm_user_assigned_identity.test.id
  transparent_data_encryption_key_vault_key_id = azurerm_key_vault_key.test.id
}

resource "azurerm_key_vault" "test" {
  name                        = "vault240311032631178793"
  location                    = azurerm_resource_group.test.location
  resource_group_name         = azurerm_resource_group.test.name
  enabled_for_disk_encryption = true
  tenant_id                   = azurerm_user_assigned_identity.test.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = true

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.test.tenant_id
    object_id = data.azurerm_client_config.test.object_id

    key_permissions = ["Get", "List", "Create", "Delete", "Update", "Recover", "Purge", "GetRotationPolicy"]
  }

  access_policy {
    tenant_id = azurerm_user_assigned_identity.test.tenant_id
    object_id = azurerm_user_assigned_identity.test.principal_id

    key_permissions = ["Get", "WrapKey", "UnwrapKey"]
  }
}

resource "azurerm_key_vault_key" "test" {
  depends_on = [azurerm_key_vault.test]

  name         = "key-s63vr"
  key_vault_id = azurerm_key_vault.test.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = ["unwrapKey", "wrapKey"]
}
