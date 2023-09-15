
provider "azurerm" {
  features {}
}


data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "test" {
  name     = "acctest-kv-RG-230915023603513742"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                = "unlikely23exst2acct441wc"
  resource_group_name = azurerm_resource_group.test.name

  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_key_vault" "test" {
  name                = "acctestkv-441wc"
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


resource "azurerm_key_vault_managed_storage_account" "test" {
  name                         = "acctestKVstorage"
  key_vault_id                 = azurerm_key_vault.test.id
  storage_account_id           = azurerm_storage_account.test.id
  storage_account_key          = "key1"
  regenerate_key_automatically = false
  regeneration_period          = "P1D"
}
