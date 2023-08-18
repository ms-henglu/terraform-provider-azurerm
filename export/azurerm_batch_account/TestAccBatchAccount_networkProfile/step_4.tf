
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batch-230818023608209758"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatchlilsc"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"
}
