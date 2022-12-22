
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batch-221222034302492051"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatchp1qj2"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"
}
