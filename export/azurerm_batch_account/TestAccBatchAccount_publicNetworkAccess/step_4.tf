
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batch-230630032737008755"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatchb48ks"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"
}
