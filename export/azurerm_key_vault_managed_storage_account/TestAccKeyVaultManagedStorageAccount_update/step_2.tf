
provider "azurerm" {
  features {}
}


data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "test" {
  name     = "acctest-kv-RG-240112224637668918"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                = "unlikely23exst2acct2hzlt"
  resource_group_name = azurerm_resource_group.test.name

  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_key_vault" "test" {
  name                = "acctestkv-2hzlt"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get",
      "Delete"
    ]

    storage_permissions = [
      "Get",
      "List",
      "Set",
      "SetSAS",
      "Update",
      "RegenerateKey"
    ]
  }
}


provider "azuread" {}

data "azuread_service_principal" "test" {
  # https://docs.microsoft.com/en-us/azure/key-vault/secrets/overview-storage-keys-powershell#service-principal-application-id
  # application_id = "cfa8b339-82a2-471a-a3c9-0fc0be7a4093"
  display_name = "Azure Key Vault"
}

resource "azurerm_role_assignment" "test" {
  scope                = azurerm_storage_account.test.id
  role_definition_name = "Storage Account Key Operator Service Role"
  principal_id         = data.azuread_service_principal.test.id
}

resource "azurerm_key_vault_managed_storage_account" "test" {
  name                         = "acctestKVstorage"
  key_vault_id                 = azurerm_key_vault.test.id
  storage_account_id           = azurerm_storage_account.test.id
  storage_account_key          = "key1"
  regenerate_key_automatically = false
  regeneration_period          = "P2D"

  tags = {
    "hello" = "world"
  }

  depends_on = [azurerm_role_assignment.test]
}
