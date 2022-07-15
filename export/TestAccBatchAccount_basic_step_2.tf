
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batch-220715004153548835"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatch6vtyd"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"

  tags = {
    env = "test"
  }
}
