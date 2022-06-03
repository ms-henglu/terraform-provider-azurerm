
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-220603005354898350"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                = "unlikely23exst2acct8bz4d"
  resource_group_name = azurerm_resource_group.test.name

  location                  = azurerm_resource_group.test.location
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  table_encryption_key_type = "Service"
  queue_encryption_key_type = "Service"
}
