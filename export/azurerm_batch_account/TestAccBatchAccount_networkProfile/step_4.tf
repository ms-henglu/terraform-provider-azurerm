
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-batch-231020040628852821"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatch0j4ic"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"
}
