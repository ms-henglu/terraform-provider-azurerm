
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batch-220324163009252883"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatch7mloj"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"
}
