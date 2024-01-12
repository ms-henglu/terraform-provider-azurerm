
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-batch-240112033924674637"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatch7r9ag"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"
}
