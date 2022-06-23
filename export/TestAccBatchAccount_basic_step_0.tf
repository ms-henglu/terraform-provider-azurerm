
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batch-220623223104148865"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatchohaz0"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"
}
