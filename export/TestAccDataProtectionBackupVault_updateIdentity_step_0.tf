

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-dataprotection-211008044320016718"
  location = "West Europe"
}


resource "azurerm_data_protection_backup_vault" "test" {
  name                = "acctest-bv-211008044320016718"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  datastore_type      = "VaultStore"
  redundancy          = "LocallyRedundant"
  identity {
    type = "SystemAssigned"
  }

  tags = {
    ENV = "Test"
  }
}
