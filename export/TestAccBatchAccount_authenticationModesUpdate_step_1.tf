
provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batch-220818234902417344"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                         = "testaccbatchkg6aa"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  pool_allocation_mode         = "BatchService"
  allowed_authentication_modes = []
}
