
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-220826003347935440"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                = "unlikely23exst2acct8y29h"
  resource_group_name = azurerm_resource_group.test.name

  location                          = azurerm_resource_group.test.location
  account_kind                      = "BlockBlobStorage"
  account_tier                      = "Premium"
  account_replication_type          = "LRS"
  infrastructure_encryption_enabled = true
}
