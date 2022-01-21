
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batch-220121044236053221"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatchd7rcd"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"
}
