
provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-Apim-220204055629046079"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-220204055629046079"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"

  sku_name = "Consumption_0"

  identity {
    type = "SystemAssigned"
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "test" {
  name                = "acctestKV-2ige3"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
}

resource "azurerm_key_vault_access_policy" "test" {
  key_vault_id = azurerm_key_vault.test.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id
  certificate_permissions = [
    "Create",
    "Delete",
    "Deleteissuers",
    "Get",
    "Getissuers",
    "Import",
    "List",
    "Listissuers",
    "Managecontacts",
    "Manageissuers",
    "Setissuers",
    "Update",
    "Purge",
  ]
  secret_permissions = [
    "Get",
    "Delete",
    "List",
    "Purge",
    "Recover",
    "Set",
  ]
}

resource "azurerm_key_vault_access_policy" "test2" {
  key_vault_id = azurerm_key_vault.test.id
  tenant_id    = azurerm_api_management.test.identity.0.tenant_id
  object_id    = azurerm_api_management.test.identity.0.principal_id
  secret_permissions = [
    "Get",
    "List",
  ]
}

resource "azurerm_key_vault_secret" "test" {
  name         = "secret-2ige3"
  value        = "rick-and-morty"
  key_vault_id = azurerm_key_vault.test.id

  depends_on = [azurerm_key_vault_access_policy.test]
}

resource "azurerm_api_management_named_value" "test" {
  name                = "acctestAMProperty-220204055629046079"
  resource_group_name = azurerm_resource_group.test.name
  api_management_name = azurerm_api_management.test.name
  display_name        = "TestKeyVault220204055629046079"
  secret              = true
  value_from_key_vault {
    secret_id = azurerm_key_vault_secret.test.id
  }

  depends_on = [azurerm_key_vault_access_policy.test2]
}
