
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batch-221221204006653800"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatcha3lqe"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"

  tags = {
    env = "test"
  }
}
