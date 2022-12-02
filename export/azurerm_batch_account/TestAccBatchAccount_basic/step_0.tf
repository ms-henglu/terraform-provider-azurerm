
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batch-221202035215970413"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatchwg24z"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"
}
