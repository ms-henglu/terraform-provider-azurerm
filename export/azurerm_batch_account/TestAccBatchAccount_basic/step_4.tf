
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batch-230313020756293256"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatchdrwvr"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"
}
