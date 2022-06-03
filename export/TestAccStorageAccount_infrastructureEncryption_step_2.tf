
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-220603005354892805"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                = "unlikely23exst2acct9dem9"
  resource_group_name = azurerm_resource_group.test.name

  location                          = azurerm_resource_group.test.location
  account_tier                      = "Standard"
  account_replication_type          = "LRS"
  infrastructure_encryption_enabled = false
}
