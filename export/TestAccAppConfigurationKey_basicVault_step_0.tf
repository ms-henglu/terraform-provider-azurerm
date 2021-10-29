

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-appconfig-211029015206828551"
  location = "West Europe"
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "example" {
  name                       = "a-v-211029015206828551"
  location                   = azurerm_resource_group.test.location
  resource_group_name        = azurerm_resource_group.test.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "premium"
  soft_delete_retention_days = 7

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "create",
      "get",
    ]

    secret_permissions = [
      "set",
      "get",
      "delete",
      "purge",
      "recover"
    ]
  }
}

resource "azurerm_key_vault_secret" "example" {
  name         = "acctest-secret-211029015206828551"
  value        = "szechuan"
  key_vault_id = azurerm_key_vault.example.id
}

resource "azurerm_app_configuration" "test" {
  name                = "testacc-appconf-211029015206828551"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "standard"
}

resource "azurerm_app_configuration_key" "test" {
  configuration_store_id = azurerm_app_configuration.test.id
  key                    = "acctest-ackey-211029015206828551"
  type                   = "vault"
  label                  = "acctest-ackeylabel-211029015206828551"
  vault_key_reference    = azurerm_key_vault_secret.example.id
}
