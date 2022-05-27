

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-dataprotection-220527034051180575"
  location = "West Europe"
}

resource "azurerm_data_protection_backup_vault" "test" {
  name                = "acctest-dbv-220527034051180575"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  datastore_type      = "VaultStore"
  redundancy          = "LocallyRedundant"
}


resource "azurerm_data_protection_backup_policy_blob_storage" "test" {
  name               = "acctest-dbp-220527034051180575"
  vault_id           = azurerm_data_protection_backup_vault.test.id
  retention_duration = "P30D"
}
