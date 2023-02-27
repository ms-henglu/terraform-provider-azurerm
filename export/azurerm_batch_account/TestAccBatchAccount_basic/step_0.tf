
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batch-230227032304357901"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatchjl0gh"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"
}
