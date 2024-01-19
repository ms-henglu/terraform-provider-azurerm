
provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-batch-240119024553044375"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatch2ec4l"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"
  allowed_authentication_modes = [
    "AAD",
    "SharedKey",
    "TaskAuthenticationToken"
  ]
}
