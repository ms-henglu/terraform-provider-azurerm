


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-dataprotection-240311031904964971"
  location = "West Europe"
}

resource "azurerm_data_protection_backup_vault" "test" {
  name                = "acctest-dbv-240311031904964971"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  datastore_type      = "VaultStore"
  redundancy          = "LocallyRedundant"
}


resource "azurerm_data_protection_backup_policy_blob_storage" "test" {
  name               = "acctest-dbp-240311031904964971"
  vault_id           = azurerm_data_protection_backup_vault.test.id
  retention_duration = "P30D"
}


resource "azurerm_data_protection_backup_policy_blob_storage" "import" {
  name               = azurerm_data_protection_backup_policy_blob_storage.test.name
  vault_id           = azurerm_data_protection_backup_policy_blob_storage.test.vault_id
  retention_duration = "P30D"
}
