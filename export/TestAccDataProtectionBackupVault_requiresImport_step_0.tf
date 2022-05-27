

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-dataprotection-220527034051188306"
  location = "West Europe"
}


resource "azurerm_data_protection_backup_vault" "test" {
  name                = "acctest-bv-220527034051188306"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  datastore_type      = "VaultStore"
  redundancy          = "LocallyRedundant"
}
