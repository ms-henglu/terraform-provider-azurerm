

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy       = false
      purge_soft_deleted_keys_on_destroy = false
    }
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-ml-230707004229167427"
  location = "West Europe"
}

resource "azurerm_application_insights" "test" {
  name                = "acctestai-230707004229167427"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  application_type    = "web"
}

resource "azurerm_key_vault" "test" {
  name                = "acctestvaultx6zzl"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name = "standard"

  purge_protection_enabled = true
}

resource "azurerm_key_vault_access_policy" "test" {
  key_vault_id = azurerm_key_vault.test.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Create",
    "Get",
    "Delete",
    "Purge",
  ]
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa230707004229127"
  location                 = azurerm_resource_group.test.location
  resource_group_name      = azurerm_resource_group.test.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_machine_learning_workspace" "test" {
  name                    = "acctest-MLW-230707004229167427"
  location                = azurerm_resource_group.test.location
  resource_group_name     = azurerm_resource_group.test.name
  application_insights_id = azurerm_application_insights.test.id
  key_vault_id            = azurerm_key_vault.test.id
  storage_account_id      = azurerm_storage_account.test.id

  identity {
    type = "SystemAssigned"
  }
}


resource "azurerm_storage_container" "test" {
  name                  = "acctestcontainer230707004229167427"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

resource "azurerm_machine_learning_datastore_datalake_gen2" "test" {
  name                 = "accdatastore230707004229167427"
  workspace_id         = azurerm_machine_learning_workspace.test.id
  storage_container_id = azurerm_storage_container.test.resource_manager_id
  tenant_id            = "ARM_TENANT_ID"
  client_id            = "ARM_CLIENT_ID"
  client_secret        = "ARM_CLIENT_SECRET"
}
