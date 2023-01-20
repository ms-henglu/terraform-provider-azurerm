
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batch-230120051554083654"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatchkg9c2"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"
}
