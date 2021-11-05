
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batch-211105035600900322"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatch8ya82"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"
}
