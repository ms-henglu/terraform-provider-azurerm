
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-batch-231218071319908397"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatchrpxf3"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"
}
