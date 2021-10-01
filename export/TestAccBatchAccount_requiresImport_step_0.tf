
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batch-211001020525733327"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatch32ma8"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"
}
