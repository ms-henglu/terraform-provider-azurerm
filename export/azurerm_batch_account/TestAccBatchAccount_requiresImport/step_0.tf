
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-batch-231020040628859666"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatchy9g9x"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"
}
