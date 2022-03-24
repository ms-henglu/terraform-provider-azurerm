
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batch-220324155947802822"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatchiv6k1"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"
}
