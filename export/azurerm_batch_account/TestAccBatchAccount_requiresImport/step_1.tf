

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batch-221221204006652653"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatch6b8uy"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"
}


resource "azurerm_batch_account" "import" {
  name                 = azurerm_batch_account.test.name
  resource_group_name  = azurerm_batch_account.test.resource_group_name
  location             = azurerm_batch_account.test.location
  pool_allocation_mode = azurerm_batch_account.test.pool_allocation_mode
}
