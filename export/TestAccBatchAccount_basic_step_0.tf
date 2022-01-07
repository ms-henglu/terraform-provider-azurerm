
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batch-220107033602727828"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatchxc3fk"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"
}
