
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batch-211021234726180053"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatch2aos1"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"
}
