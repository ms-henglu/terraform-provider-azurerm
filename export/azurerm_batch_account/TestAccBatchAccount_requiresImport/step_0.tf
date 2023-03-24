
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batch-230324051656313207"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatch3ce1q"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"
}
