
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batch-230127045030021835"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatch1cxhn"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"
}
