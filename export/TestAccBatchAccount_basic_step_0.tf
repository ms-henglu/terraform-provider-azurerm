
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batch-220916011129698686"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatch3e0iy"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"
}
