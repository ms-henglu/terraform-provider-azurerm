


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-dataprotection-210928075406024275"
  location = "West Europe"
}


resource "azurerm_data_protection_backup_vault" "test" {
  name                = "acctest-bv-210928075406024275"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  datastore_type      = "VaultStore"
  redundancy          = "LocallyRedundant"
}


resource "azurerm_data_protection_backup_vault" "import" {
  name                = azurerm_data_protection_backup_vault.test.name
  resource_group_name = azurerm_data_protection_backup_vault.test.resource_group_name
  location            = azurerm_data_protection_backup_vault.test.location
  datastore_type      = azurerm_data_protection_backup_vault.test.datastore_type
  redundancy          = azurerm_data_protection_backup_vault.test.redundancy
}
