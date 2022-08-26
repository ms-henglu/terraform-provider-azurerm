
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220826002719007866"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestegst220826002766"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_eventgrid_system_topic" "test" {
  name                   = "acctestEGST220826002719007866"
  location               = azurerm_resource_group.test.location
  resource_group_name    = azurerm_resource_group.test.name
  source_arm_resource_id = azurerm_storage_account.test.id
  topic_type             = "Microsoft.Storage.StorageAccounts"
}
