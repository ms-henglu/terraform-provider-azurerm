
provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-batch-230922053707472816"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                         = "testaccbatchn7n8x"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  pool_allocation_mode         = "BatchService"
  allowed_authentication_modes = []
}
