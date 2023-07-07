

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-dataprotection-230707003744262454"
  location = "West Europe"
}

resource "azurerm_data_protection_backup_vault" "test" {
  name                = "acctest-dbv-230707003744262454"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  datastore_type      = "VaultStore"
  redundancy          = "LocallyRedundant"
}


resource "azurerm_data_protection_backup_policy_disk" "test" {
  name                            = "acctest-dbp-230707003744262454"
  vault_id                        = azurerm_data_protection_backup_vault.test.id
  backup_repeating_time_intervals = ["R/2021-05-19T06:33:16+00:00/PT4H"]
  default_retention_duration      = "P7D"
}
