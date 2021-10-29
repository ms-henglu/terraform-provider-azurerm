
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batch-211029015253433826"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatchno9su"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"
}
