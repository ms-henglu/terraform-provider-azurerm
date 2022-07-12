
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batch-220712042000693168"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatchy81ro"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"
}
