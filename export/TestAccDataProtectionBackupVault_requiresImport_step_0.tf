

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-dataprotection-211015014140306373"
  location = "West Europe"
}


resource "azurerm_data_protection_backup_vault" "test" {
  name                = "acctest-bv-211015014140306373"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  datastore_type      = "VaultStore"
  redundancy          = "LocallyRedundant"
}
