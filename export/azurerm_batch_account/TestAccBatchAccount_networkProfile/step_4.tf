
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-batch-230922053707477003"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatchnhjsr"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"
}
