
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batch-220128082128326374"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatchkquk8"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"
}
