

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-dataprotection-230106034353508076"
  location = "West Europe"
}


resource "azurerm_data_protection_backup_vault" "test" {
  name                = "acctest-bv-230106034353508076"
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
