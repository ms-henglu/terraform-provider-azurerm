
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221221204006655583"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsau8jdb"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_batch_account" "test" {
  name                                = "acctestbau8jdb"
  resource_group_name                 = azurerm_resource_group.test.name
  location                            = azurerm_resource_group.test.location
  pool_allocation_mode                = "BatchService"
  storage_account_id                  = azurerm_storage_account.test.id
  storage_account_authentication_mode = "StorageKeys"
}

resource "azurerm_batch_application" "test" {
  name                = "acctestbatchapp-221221204006655583"
  resource_group_name = azurerm_resource_group.test.name
  account_name        = azurerm_batch_account.test.name
  allow_updates       = true
  display_name        = "TestAccDisplayName"
  
}
