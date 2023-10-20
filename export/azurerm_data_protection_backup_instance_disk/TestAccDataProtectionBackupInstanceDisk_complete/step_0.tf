

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-dataprotection-231020040932839254"
  location = "West Europe"
}

resource "azurerm_managed_disk" "test" {
  name                 = "acctest-disk-23102054"
  location             = azurerm_resource_group.test.location
  resource_group_name  = azurerm_resource_group.test.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1"
}

resource "azurerm_data_protection_backup_vault" "test" {
  name                = "acctest-dataprotection-vault-231020040932839254"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  datastore_type      = "VaultStore"
  redundancy          = "LocallyRedundant"

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "test1" {
  scope                = azurerm_resource_group.test.id
  role_definition_name = "Disk Snapshot Contributor"
  principal_id         = azurerm_data_protection_backup_vault.test.identity[0].principal_id
}

resource "azurerm_role_assignment" "test2" {
  scope                = azurerm_managed_disk.test.id
  role_definition_name = "Disk Backup Reader"
  principal_id         = azurerm_data_protection_backup_vault.test.identity[0].principal_id
}

resource "azurerm_data_protection_backup_policy_disk" "test" {
  name                            = "acctest-dbp-231020040932839254"
  vault_id                        = azurerm_data_protection_backup_vault.test.id
  backup_repeating_time_intervals = ["R/2021-05-20T04:54:23+00:00/PT4H"]
  default_retention_duration      = "P7D"
}

resource "azurerm_data_protection_backup_policy_disk" "another" {
  name                            = "acctest-dbp-other-231020040932839254"
  vault_id                        = azurerm_data_protection_backup_vault.test.id
  backup_repeating_time_intervals = ["R/2021-05-20T04:54:23+00:00/PT4H"]
  default_retention_duration      = "P10D"
}


resource "azurerm_data_protection_backup_instance_disk" "test" {
  name                         = "acctest-dbi-231020040932839254"
  location                     = azurerm_resource_group.test.location
  vault_id                     = azurerm_data_protection_backup_vault.test.id
  disk_id                      = azurerm_managed_disk.test.id
  snapshot_resource_group_name = azurerm_resource_group.test.name
  backup_policy_id             = azurerm_data_protection_backup_policy_disk.test.id
}
