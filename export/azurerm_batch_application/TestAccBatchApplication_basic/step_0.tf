
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230804025509055946"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsayrgfp"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_batch_account" "test" {
  name                                = "acctestbayrgfp"
  resource_group_name                 = azurerm_resource_group.test.name
  location                            = azurerm_resource_group.test.location
  pool_allocation_mode                = "BatchService"
  storage_account_id                  = azurerm_storage_account.test.id
  storage_account_authentication_mode = "StorageKeys"
}

resource "azurerm_batch_application" "test" {
  name                = "acctestbatchapp-230804025509055946"
  resource_group_name = azurerm_resource_group.test.name
  account_name        = azurerm_batch_account.test.name
  
}
