
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batch-220627123855999498"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatchd7r78"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"
}
