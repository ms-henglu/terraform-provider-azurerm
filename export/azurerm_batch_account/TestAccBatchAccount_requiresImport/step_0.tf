
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batch-230609090903663866"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatchukqs1"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"
}
