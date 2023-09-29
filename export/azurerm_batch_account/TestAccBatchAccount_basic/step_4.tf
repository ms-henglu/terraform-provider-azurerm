
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-batch-230929064440514290"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatchmtvqf"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"
}
