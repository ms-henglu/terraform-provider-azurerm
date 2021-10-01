
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211001020525732158"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsav1qye"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_batch_account" "test" {
  name                 = "acctestbav1qye"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  pool_allocation_mode = "BatchService"
  storage_account_id   = azurerm_storage_account.test.id
}

resource "azurerm_batch_application" "test" {
  name                = "acctestbatchapp-211001020525732158"
  resource_group_name = azurerm_resource_group.test.name
  account_name        = azurerm_batch_account.test.name
  display_name = "TestAccDisplayName-211001020525732158"
}
