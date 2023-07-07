
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batch-230707003419455984"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatch00nad"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"
}
