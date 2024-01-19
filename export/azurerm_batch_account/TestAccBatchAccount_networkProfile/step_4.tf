
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-batch-240119021618213802"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatchk4i9c"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"
}
