
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batch-220627130821416938"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatchllmij"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"
}
