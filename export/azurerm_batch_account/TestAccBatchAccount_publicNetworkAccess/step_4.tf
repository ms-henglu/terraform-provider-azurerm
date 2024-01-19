
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-batch-240119024553041020"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatchga8pm"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"
}
