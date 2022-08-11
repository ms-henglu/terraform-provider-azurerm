
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batch-220811052918531665"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatchlrn2p"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"
}
