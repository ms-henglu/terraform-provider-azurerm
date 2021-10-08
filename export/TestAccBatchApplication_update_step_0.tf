
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211008044112176552"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsaavihk"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_batch_account" "test" {
  name                 = "acctestbaavihk"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"
  storage_account_id   = azurerm_storage_account.test.id
}

resource "azurerm_batch_application" "test" {
  name                = "acctestbatchapp-211008044112176552"
  resource_group_name = azurerm_resource_group.test.name
  account_name        = azurerm_batch_account.test.name
  
}
