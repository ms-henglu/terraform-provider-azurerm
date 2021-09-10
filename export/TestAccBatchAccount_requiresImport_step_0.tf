
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batch-210910021130158732"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatche7wop"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"
}
