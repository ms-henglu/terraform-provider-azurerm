
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batch-220520040406653027"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatch46jcr"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"
}
