
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batch-221021033825266821"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatchz38n7"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"

  public_network_access_enabled = false

  tags = {
    env = "test"
  }
}
