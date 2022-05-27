
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batch-220527033848863037"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatchci3eg"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"
}
