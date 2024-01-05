
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-batch-240105060326795981"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatchssu1x"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"
}
