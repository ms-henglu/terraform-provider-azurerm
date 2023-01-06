
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batch-230106034142951247"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatchr21s2"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"
}
