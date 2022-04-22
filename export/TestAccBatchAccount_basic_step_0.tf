
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batch-220422024828309720"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatchurj46"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"
}
