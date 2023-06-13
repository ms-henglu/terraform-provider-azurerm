


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-dataprotection-230613071727362192"
  location = "West Europe"
}

resource "azurerm_data_protection_backup_vault" "test" {
  name                = "acctest-dbv-230613071727362192"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  datastore_type      = "VaultStore"
  redundancy          = "LocallyRedundant"
}


resource "azurerm_data_protection_backup_policy_disk" "test" {
  name                            = "acctest-dbp-230613071727362192"
  vault_id                        = azurerm_data_protection_backup_vault.test.id
  backup_repeating_time_intervals = ["R/2021-05-19T06:33:16+00:00/PT4H"]
  default_retention_duration      = "P7D"
}


resource "azurerm_data_protection_backup_policy_disk" "import" {
  name                            = azurerm_data_protection_backup_policy_disk.test.name
  vault_id                        = azurerm_data_protection_backup_policy_disk.test.vault_id
  backup_repeating_time_intervals = ["R/2021-05-19T06:33:16+00:00/PT4H"]
  default_retention_duration      = "P7D"
}
