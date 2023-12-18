
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-batch-231218071319905251"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatchw4zsc"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"
}
