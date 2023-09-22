

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

data "azuread_service_principal" "test" {
  display_name = "Azure Logic Apps"
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-logic-230922054406115006"
  location = "West Europe"
}

resource "azurerm_key_vault" "test" {
  name                = "acctestkv-mofbt"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
}

resource "azurerm_key_vault_access_policy" "test1" {
  key_vault_id = azurerm_key_vault.test.id

  key_permissions = [
    "Create",
    "Delete",
    "Get",
    "Purge",
    "Recover",
    "Update",
    "List",
    "Decrypt",
    "Sign",
    "GetRotationPolicy"
  ]

  secret_permissions = [
    "Get",
    "Set",
  ]

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azuread_service_principal.test.object_id
}

resource "azurerm_key_vault_access_policy" "test2" {
  key_vault_id = azurerm_key_vault.test.id

  key_permissions = [
    "Create",
    "Delete",
    "Get",
    "Purge",
    "Recover",
    "Update",
    "List",
    "Decrypt",
    "Sign",
    "GetRotationPolicy"
  ]

  secret_permissions = [
    "Get",
    "Set",
  ]

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_client_config.current.object_id
}

resource "azurerm_key_vault_key" "test" {
  name         = "acctestkvkey-mofbt"
  key_vault_id = azurerm_key_vault.test.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey"
  ]

  depends_on = [azurerm_key_vault_access_policy.test1, azurerm_key_vault_access_policy.test2]
}

resource "azurerm_logic_app_integration_account" "test" {
  name                = "acctestia-230922054406115006"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Standard"
}


resource "azurerm_logic_app_integration_account_certificate" "test" {
  name                     = "acctest-iac-230922054406115006"
  resource_group_name      = azurerm_resource_group.test.name
  integration_account_name = azurerm_logic_app_integration_account.test.name

  key_vault_key {
    key_name     = azurerm_key_vault_key.test.name
    key_vault_id = azurerm_key_vault.test.id
    key_version  = azurerm_key_vault_key.test.version
  }
}
