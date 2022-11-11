
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batch-221111013134876515"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatchksf0a"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"

  tags = {
    env = "test"
  }
}
