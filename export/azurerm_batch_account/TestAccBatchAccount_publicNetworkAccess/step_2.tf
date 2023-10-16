
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-batch-231016033447865519"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatchya80y"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"

  public_network_access_enabled = false
}
