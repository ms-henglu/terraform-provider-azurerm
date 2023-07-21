

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-dataprotection-230721011517890185"
  location = "West Europe"
}

resource "azurerm_data_protection_backup_vault" "test" {
  name                = "acctest-dbv-230721011517890185"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  datastore_type      = "VaultStore"
  redundancy          = "LocallyRedundant"
}


resource "azurerm_data_protection_backup_policy_blob_storage" "test" {
  name               = "acctest-dbp-230721011517890185"
  vault_id           = azurerm_data_protection_backup_vault.test.id
  retention_duration = "P30D"
}
