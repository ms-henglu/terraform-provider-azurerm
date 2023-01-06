
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batch-230106031147881119"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatchu7zrw"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"

  tags = {
    env = "test"
  }
}
