
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batch-220429075135406673"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatchj8bxj"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"
}
