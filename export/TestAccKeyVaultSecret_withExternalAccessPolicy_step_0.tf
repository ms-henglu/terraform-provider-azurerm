
provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210924011112592859"
  location = "West Europe"
}

resource "azurerm_key_vault" "test" {
  name                       = "acctestkv-n9chg"
  location                   = azurerm_resource_group.test.location
  resource_group_name        = azurerm_resource_group.test.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_enabled        = true
  soft_delete_retention_days = 7

  tags = {
    environment = "Production"
  }
}

resource "azurerm_key_vault_access_policy" "test" {
  key_vault_id = azurerm_key_vault.test.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id
  key_permissions = [
    "Create",
    "Get",
  ]
  secret_permissions = [
    "Set",
    "Get",
    "Delete",
    "Purge",
    "Recover"
  ]
}

resource "azurerm_key_vault_secret" "test" {
  name         = "secret-n9chg"
  value        = "rick-and-morty"
  key_vault_id = azurerm_key_vault.test.id
  depends_on   = [azurerm_key_vault_access_policy.test]
}
