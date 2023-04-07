
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

data "azuread_service_principal" "test" {
  display_name = "Bot Service CMEK Prod"
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230407023004516627"
  location = "West Europe"
}

resource "azurerm_application_insights" "test" {
  name                = "acctestappinsights-230407023004516627"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  application_type    = "web"
}

resource "azurerm_application_insights_api_key" "test" {
  name                    = "acctestappinsightsapikey-230407023004516627"
  application_insights_id = azurerm_application_insights.test.id
  read_permissions        = ["aggregate", "api", "draft", "extendqueries", "search"]
}

resource "azurerm_application_insights" "test2" {
  name                = "acctestappinsights2-230407023004516627"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  application_type    = "web"
}

resource "azurerm_application_insights_api_key" "test2" {
  name                    = "acctestappinsightsapikey2-230407023004516627"
  application_insights_id = azurerm_application_insights.test2.id
  read_permissions        = ["aggregate", "api", "draft", "extendqueries", "search"]
}

resource "azurerm_key_vault" "test" {
  name                     = "acctestkv-i1qqx"
  location                 = azurerm_resource_group.test.location
  resource_group_name      = azurerm_resource_group.test.name
  tenant_id                = data.azurerm_client_config.current.tenant_id
  sku_name                 = "standard"
  purge_protection_enabled = true
}

resource "azurerm_key_vault_access_policy" "test" {
  key_vault_id = azurerm_key_vault.test.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions    = ["Get", "Create", "Delete", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify", "GetRotationPolicy"]
  secret_permissions = ["Get"]
}

resource "azurerm_key_vault_access_policy" "test2" {
  key_vault_id = azurerm_key_vault.test.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azuread_service_principal.test.id

  key_permissions    = ["Get", "Create", "Delete", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify", "GetRotationPolicy"]
  secret_permissions = ["Get"]
}

resource "azurerm_key_vault_key" "test" {
  name         = "acctestkvkey-i1qqx"
  key_vault_id = azurerm_key_vault.test.id
  key_type     = "RSA"
  key_size     = 2048
  key_opts     = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]

  depends_on = [
    azurerm_key_vault_access_policy.test,
    azurerm_key_vault_access_policy.test2,
  ]
}

resource "azurerm_key_vault_key" "test2" {
  name         = "acctestkvkey2-i1qqx"
  key_vault_id = azurerm_key_vault.test.id
  key_type     = "RSA"
  key_size     = 2048
  key_opts     = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]

  depends_on = [
    azurerm_key_vault_access_policy.test,
    azurerm_key_vault_access_policy.test2,
  ]
}

resource "azurerm_bot_channels_registration" "test" {
  name                = "acctestdf230407023004516627"
  location            = "global"
  resource_group_name = azurerm_resource_group.test.name
  microsoft_app_id    = data.azurerm_client_config.current.client_id
  sku                 = "F0"

  endpoint                              = "https://example2.com"
  developer_app_insights_api_key        = azurerm_application_insights_api_key.test2.api_key
  developer_app_insights_application_id = azurerm_application_insights.test2.app_id

  description              = "TestDescription2"
  isolated_network_enabled = false
  icon_url                 = "http://myprofile/myicon2.png"
  cmk_key_vault_url        = azurerm_key_vault_key.test2.id

  tags = {
    environment = "production2"
  }
}
