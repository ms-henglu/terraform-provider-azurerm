
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-batch-230922060658192519"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatchsedfg"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"
}
