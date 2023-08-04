
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batch-230804025509050088"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "testaccsa6e23i"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatch6e23i"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"

  public_network_access_enabled = false

  tags = {
    env = "test"
  }
}
