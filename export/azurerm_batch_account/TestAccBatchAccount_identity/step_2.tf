
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batch-230512010257544727"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "testaccsacg212"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestcg212"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_batch_account" "test" {
  name                                = "testaccbatchcg212"
  resource_group_name                 = azurerm_resource_group.test.name
  location                            = azurerm_resource_group.test.location
  pool_allocation_mode                = "BatchService"
  storage_account_id                  = azurerm_storage_account.test.id
  storage_account_authentication_mode = "StorageKeys"
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.test.id]
  }
}
