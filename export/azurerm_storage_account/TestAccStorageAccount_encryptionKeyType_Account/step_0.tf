
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-230512011501410849"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                = "unlikely23exst2acct4m1a9"
  resource_group_name = azurerm_resource_group.test.name

  location                  = azurerm_resource_group.test.location
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  table_encryption_key_type = "Account"
  queue_encryption_key_type = "Account"
}
