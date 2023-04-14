
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batch-230414020821421703"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatchj7k1l"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"
}
