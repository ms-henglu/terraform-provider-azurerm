
provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batch-230505045925069282"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                         = "testaccbatchdj8zk"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  pool_allocation_mode         = "BatchService"
  allowed_authentication_modes = []
}
