
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batch-211015014347648561"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "testaccsaiuipq2"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatchiuipq"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"
  storage_account_id   = azurerm_storage_account.test.id

  public_network_access_enabled = false

  tags = {
    env     = "test"
    version = "2"
  }
}
