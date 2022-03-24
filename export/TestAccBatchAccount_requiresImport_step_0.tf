
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batch-220324175957830385"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                 = "testaccbatchmfyua"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"
}
