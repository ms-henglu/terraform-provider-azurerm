
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batch-210928055203765454"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatchio2nr"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"
}
