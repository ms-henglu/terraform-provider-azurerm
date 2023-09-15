
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-batch-230915022950063312"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatchl61yx"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"
}
