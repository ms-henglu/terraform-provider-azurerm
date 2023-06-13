
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batch-230613071418607141"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatch2c8hn"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"
}
