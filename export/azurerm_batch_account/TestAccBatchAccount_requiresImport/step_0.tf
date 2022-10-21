
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batch-221021033825262518"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatche1198"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"
}
