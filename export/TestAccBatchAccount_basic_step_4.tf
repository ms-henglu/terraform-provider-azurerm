
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batch-220715014212058833"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatch0pzbf"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"
}
