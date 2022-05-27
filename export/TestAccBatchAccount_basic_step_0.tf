
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batch-220527023906225020"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatchazf7a"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"
}
