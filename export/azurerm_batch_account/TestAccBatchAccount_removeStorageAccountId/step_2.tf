
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-batch-240119024553041235"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "testaccsatisg4"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatchtisg4"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"

  public_network_access_enabled = false

  tags = {
    env = "test"
  }
}
