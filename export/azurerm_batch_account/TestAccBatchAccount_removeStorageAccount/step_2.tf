
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batch-230512010257556815"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatch3d42z"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"

  public_network_access_enabled = false

  tags = {
    env = "test"
  }
}
