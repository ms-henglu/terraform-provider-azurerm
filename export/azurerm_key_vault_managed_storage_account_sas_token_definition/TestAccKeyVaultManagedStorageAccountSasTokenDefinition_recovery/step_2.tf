
provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = "false"
      recover_soft_deleted_key_vaults = true
    }
  }
}


data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "test" {
  name     = "acctest-kv-RG-230721015320506876"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                = "unlikely23exst2acct6etp9"
  resource_group_name = azurerm_resource_group.test.name

  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

data "azurerm_storage_account_sas" "test" {
  connection_string = azurerm_storage_account.test.primary_connection_string
  https_only        = true

  resource_types {
    service   = true
    container = false
    object    = false
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  start  = "2021-04-30T00:00:00Z"
  expiry = "2023-04-30T00:00:00Z"

  permissions {
    read    = true
    write   = true
    delete  = false
    list    = false
    add     = true
    create  = true
    update  = false
    process = false
    tag     = false
    filter  = false
  }
}

resource "azurerm_key_vault" "test" {
  name                = "acctestkv-6etp9"
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
      "GetSAS",
      "DeleteSAS",
      "Update",
      "RegenerateKey"
    ]
  }
}


resource "azurerm_key_vault_managed_storage_account" "test" {
  name                         = "acctestKVstorage1"
  key_vault_id                 = azurerm_key_vault.test.id
  storage_account_id           = azurerm_storage_account.test.id
  storage_account_key          = "key1"
  regenerate_key_automatically = false
  regeneration_period          = "P1D"
}

resource "azurerm_key_vault_managed_storage_account_sas_token_definition" "test" {
  name                       = "acctestKVsasdefinition1"
  managed_storage_account_id = azurerm_key_vault_managed_storage_account.test.id
  sas_type                   = "account"
  sas_template_uri           = data.azurerm_storage_account_sas.test.sas
  validity_period            = "P1D"
}
