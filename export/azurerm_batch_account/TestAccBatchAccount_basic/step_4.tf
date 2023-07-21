
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batch-230721014548085837"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatche8a1c"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"
}
