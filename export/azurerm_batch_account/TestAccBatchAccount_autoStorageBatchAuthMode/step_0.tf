
provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batch-230616074334667237"
  location = "West US 2"
}

resource "azurerm_storage_account" "test" {
  name                     = "testaccsau7jn3"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestu7jn3"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_batch_account" "test" {
  name                                = "testaccbatchu7jn3"
  resource_group_name                 = azurerm_resource_group.test.name
  location                            = azurerm_resource_group.test.location
  storage_account_id                  = azurerm_storage_account.test.id
  storage_account_authentication_mode = "BatchAccountManagedIdentity"
  pool_allocation_mode                = "BatchService"
  allowed_authentication_modes = [
    "AAD",
    "SharedKey",
    "TaskAuthenticationToken"
  ]

  identity {
    type = "SystemAssigned"
  }
}
