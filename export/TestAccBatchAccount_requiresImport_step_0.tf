
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batch-210825025544794149"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatchyu6lr"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"
}
