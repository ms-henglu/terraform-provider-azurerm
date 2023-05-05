

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-dataprotection-230505050255984584"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa23050584"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_data_protection_backup_vault" "test" {
  name                = "acctest-dataprotection-vault-230505050255984584"
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
  name               = "acctest-dbp-230505050255984584"
  vault_id           = azurerm_data_protection_backup_vault.test.id
  retention_duration = "P30D"
}

resource "azurerm_data_protection_backup_policy_blob_storage" "another" {
  name               = "acctest-dbp-other-230505050255984584"
  vault_id           = azurerm_data_protection_backup_vault.test.id
  retention_duration = "P30D"
}

resource "azurerm_data_protection_backup_instance_blob_storage" "test" {
  name               = "acctest-dbi-230505050255984584"
  location           = azurerm_resource_group.test.location
  vault_id           = azurerm_data_protection_backup_vault.test.id
  storage_account_id = azurerm_storage_account.test.id
  backup_policy_id   = azurerm_data_protection_backup_policy_blob_storage.another.id

  depends_on = [azurerm_role_assignment.test]
}
