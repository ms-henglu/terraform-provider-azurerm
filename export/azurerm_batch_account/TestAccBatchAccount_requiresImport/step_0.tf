
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batch-230825024120204703"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatchhhq3o"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"
}
