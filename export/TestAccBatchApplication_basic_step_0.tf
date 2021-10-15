
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211015014347642277"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsavj9pq"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_batch_account" "test" {
  name                 = "acctestbavj9pq"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"
  storage_account_id   = azurerm_storage_account.test.id
}

resource "azurerm_batch_application" "test" {
  name                = "acctestbatchapp-211015014347642277"
  resource_group_name = azurerm_resource_group.test.name
  account_name        = azurerm_batch_account.test.name
  
}
