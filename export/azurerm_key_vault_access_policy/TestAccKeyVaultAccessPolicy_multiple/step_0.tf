
provider "azurerm" {
  features {}
}


data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240315123252639689"
  location = "West Europe"
}

resource "azurerm_key_vault" "test" {
  name                = "acctestkv-jp9a9"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
}


resource "azurerm_key_vault_access_policy" "test_with_application_id" {
  key_vault_id = azurerm_key_vault.test.id

  key_permissions = [
    "Create",
    "Get",
  ]

  secret_permissions = [
    "Get",
    "Delete",
  ]

  certificate_permissions = [
    "Create",
    "Delete",
  ]

  application_id = data.azurerm_client_config.current.client_id
  tenant_id      = data.azurerm_client_config.current.tenant_id
  object_id      = data.azurerm_client_config.current.object_id
}

resource "azurerm_key_vault_access_policy" "test_no_application_id" {
  key_vault_id = azurerm_key_vault.test.id

  key_permissions = [
    "List",
    "Encrypt",
  ]

  secret_permissions = [
    "List",
    "Delete",
  ]

  certificate_permissions = [
    "List",
    "Delete",
  ]

  storage_permissions = [
    "Backup",
    "Delete",
    "DeleteSAS",
    "Get",
    "GetSAS",
    "List",
    "ListSAS",
    "Purge",
    "Recover",
    "RegenerateKey",
    "Restore",
    "Set",
    "SetSAS",
    "Update",
  ]

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_client_config.current.object_id
}
