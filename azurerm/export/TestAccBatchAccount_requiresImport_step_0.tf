
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batch-220627134251940182"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatch6nct8"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"
}
