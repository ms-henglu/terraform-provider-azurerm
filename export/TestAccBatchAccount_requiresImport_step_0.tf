
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batch-211015014347645140"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatch8m77e"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"
}
