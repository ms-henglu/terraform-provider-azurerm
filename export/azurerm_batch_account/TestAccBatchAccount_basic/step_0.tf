
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-batch-231020040628855439"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatch0yv0g"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"
}
