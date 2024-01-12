


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-dataprotection-240112224325222395"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa24011295"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_data_protection_backup_vault" "test" {
  name                = "acctest-dataprotection-vault-240112224325222395"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  datastore_type      = "VaultStore"
  redundancy          = "LocallyRedundant"
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "test" {
  scope                = azurerm_storage_account.test.id
  role_definition_name = "Storage Account Backup Contributor"
  principal_id         = azurerm_data_protection_backup_vault.test.identity[0].principal_id
}

resource "azurerm_data_protection_backup_policy_blob_storage" "test" {
  name               = "acctest-dbp-240112224325222395"
  vault_id           = azurerm_data_protection_backup_vault.test.id
  retention_duration = "P30D"
}

resource "azurerm_data_protection_backup_policy_blob_storage" "another" {
  name               = "acctest-dbp-other-240112224325222395"
  vault_id           = azurerm_data_protection_backup_vault.test.id
  retention_duration = "P30D"
}

resource "azurerm_data_protection_backup_instance_blob_storage" "test" {
  name               = "acctest-dbi-240112224325222395"
  location           = azurerm_resource_group.test.location
  vault_id           = azurerm_data_protection_backup_vault.test.id
  storage_account_id = azurerm_storage_account.test.id
  backup_policy_id   = azurerm_data_protection_backup_policy_blob_storage.test.id

  depends_on = [azurerm_role_assignment.test]
}

resource "azurerm_data_protection_backup_instance_blob_storage" "import" {
  name               = azurerm_data_protection_backup_instance_blob_storage.test.name
  location           = azurerm_data_protection_backup_instance_blob_storage.test.location
  vault_id           = azurerm_data_protection_backup_instance_blob_storage.test.vault_id
  storage_account_id = azurerm_data_protection_backup_instance_blob_storage.test.storage_account_id
  backup_policy_id   = azurerm_data_protection_backup_instance_blob_storage.test.backup_policy_id

  depends_on = [azurerm_role_assignment.test]
}
