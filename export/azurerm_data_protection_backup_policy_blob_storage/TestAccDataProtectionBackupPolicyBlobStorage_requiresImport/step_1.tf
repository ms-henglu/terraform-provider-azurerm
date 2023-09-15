


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-dataprotection-230915023254748023"
  location = "West Europe"
}

resource "azurerm_data_protection_backup_vault" "test" {
  name                = "acctest-dbv-230915023254748023"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  datastore_type      = "VaultStore"
  redundancy          = "LocallyRedundant"
}


resource "azurerm_data_protection_backup_policy_blob_storage" "test" {
  name               = "acctest-dbp-230915023254748023"
  vault_id           = azurerm_data_protection_backup_vault.test.id
  retention_duration = "P30D"
}


resource "azurerm_data_protection_backup_policy_blob_storage" "import" {
  name               = azurerm_data_protection_backup_policy_blob_storage.test.name
  vault_id           = azurerm_data_protection_backup_policy_blob_storage.test.vault_id
  retention_duration = "P30D"
}
