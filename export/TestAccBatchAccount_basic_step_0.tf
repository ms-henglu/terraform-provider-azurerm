
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batch-220107063701678871"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatchucjfj"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"
}
