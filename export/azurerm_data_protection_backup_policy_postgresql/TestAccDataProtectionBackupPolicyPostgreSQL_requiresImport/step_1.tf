


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-dataprotection-231020040932833458"
  location = "West Europe"
}

resource "azurerm_data_protection_backup_vault" "test" {
  name                = "acctest-dbv-231020040932833458"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  datastore_type      = "VaultStore"
  redundancy          = "LocallyRedundant"
}


resource "azurerm_data_protection_backup_policy_postgresql" "test" {
  name                = "acctest-dbp-231020040932833458"
  resource_group_name = azurerm_resource_group.test.name
  vault_name          = azurerm_data_protection_backup_vault.test.name

  backup_repeating_time_intervals = ["R/2021-05-23T02:30:00+00:00/P1W"]
  default_retention_duration      = "P4M"
}


resource "azurerm_data_protection_backup_policy_postgresql" "import" {
  name                = azurerm_data_protection_backup_policy_postgresql.test.name
  resource_group_name = azurerm_data_protection_backup_policy_postgresql.test.resource_group_name
  vault_name          = azurerm_data_protection_backup_policy_postgresql.test.vault_name

  backup_repeating_time_intervals = ["R/2021-05-23T02:30:00+00:00/P1W"]
  default_retention_duration      = "P4M"
}
