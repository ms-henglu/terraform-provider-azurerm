
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211013071551269900"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa71283"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_batch_account" "test" {
  name                 = "acctestba71283"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"
  storage_account_id   = azurerm_storage_account.test.id
}

resource "azurerm_batch_application" "test" {
  name                = "acctestbatchapp-211013071551269900"
  resource_group_name = azurerm_resource_group.test.name
  account_name        = azurerm_batch_account.test.name
  
}
